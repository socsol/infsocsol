;; Copyright 2014 Alastair Pharo

;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at

;;     http://www.apache.org/licenses/LICENSE-2.0

;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.

(ns infsocsol.core-test
  (:use midje.sweet
        (incanter core stats charts))
  (:require [cljlab.core :as cl]
            [cljlab.util :as util]))

(def lab (atom nil))
(def model (atom nil))

;; This comes from a paper by Jacek
(def example-a-slope (- (/ (+ -0.9 (sqrt (+ (pow 0.9 2) 4.0))) 2.0)))

;; This comes from performing constrained minimisation on the problem
(def fisheries-profix-max-steady [302.5000 0.3967])

(defn set-lab-type
  "Makes sure the lab atom is of the correct type"
  [type]
  (if (or (nil? @lab)
          (not= (cl/type @lab) type)
          (not (cl/open? @lab)))
    (do
      (if @lab (cl/exit @lab))
      (reset! lab (cl/open {:type type :out *out*}))
      (cl/eval @lab "diary infsocsol.core-test.log"))))

(defmacro with-paths
  "evaluates a form with a given set of paths the lab's search-path"
  [lab paths & forms]
  `(do (println "addpath")
       (doall (map #(util/call-fn-with-basic-vals ~lab 0 0 :addpath %) ~paths))
       (try
         (do ~@forms)
         (finally
           (println "rmpath")
           (doall (map #(util/call-fn-with-basic-vals ~lab 0 0 :rmpath %) ~paths))))))

(defmacro with-plots
  "evaluates forms and closes all open handles afterwards"
  [lab & forms]
  `(let [return# (do ~@forms)]
     (cl/eval ~lab "close all hidden")
     return#))

(fact-group
 :polimp
 (tabular
  (with-state-changes [(before :facts (set-lab-type ?type))]

    (fact "the policy improvement algorithm can produce the same policies as in InfSOCSol2"
          (with-paths @lab ["tests/example_a_polimp"]

            ;; Setup: load the policy data from ISS2 (stored in .mat
            ;; files) and run the ISS3 policy improvement algorithm
            ;; bootstrapped so that it produces the same results
            ;; as in ISS2.
            (let [policies (do (util/call-fn-with-basic-vals @lab 0 0 :load ?file)
                               (matrix (cl/get @lab :Policies)))
                  dims (cl/size @lab :Policies)
                  p (-> @lab
                        (util/call-fn-with-basic-vals 0 1 :check_polimp
                                                      [?state-step]
                                                      [?time-step]
                                                      [?max-fun-evals]
                                                      [?tol-fun])
                        first
                        (cl/reshape dims)
                        matrix)]

              ;; Check that every column (which represents a policy
              ;; improvement round) is the same.
              (doall (map (fn [i]
                            (sel p :cols i) => (sel policies :cols i))
                          (range (nth dims 1))))))))

  ?type    ?state-step ?time-step ?max-fun-evals ?tol-fun  ?file
  :matlab  0.01        0.02       400            1e-12     "example_a51_policies.mat"
  :matlab  0.001       0.002      400            1e-12     "example_a501_policies.mat"))

(fact-group
 :example-a
 (tabular
  (with-state-changes [(before :facts (set-lab-type ?type))]
    (facts "about the Example A control policy"
           (with-paths @lab ["tests/example_a"]
             (util/call-fn-with-basic-vals @lab 0 0 :solve
                                           [?state-step]
                                           [?time-step]
                                           [?max-fun-evals]
                                           [?tol-fun])

             ;; Check that the plot actually appears
             (fact "it plots without errors"
                   (with-plots @lab
                     (cl/eval @lab "plot_controls")
                     (first (util/call-fn-with-basic-vals @lab 0 1 :gcf))) =not=> empty?)

             ;; Here we run the plot, but make sure it is closed
             (with-state-changes
               [(before :facts (with-plots @lab
                                 (cl/eval @lab "plot_controls")))]

               (fact "it sets the 'controls' variable to a vector"
                     (cl/get @lab :controls) => vector?)

               ;; Use incanter to do an OLS regression on the plot
               (with-state-changes
                 [(before :facts
                          (reset! model (linear-model (-> (cl/get @lab :controls) rest butlast matrix)
                                                      (range 0 (+ 0.5 ?state-step) ?state-step))))
                  (after :facts (reset! model nil))]

                 (fact "the plot was analysed by incanter"
                       @model =not=> nil)

                 (fact "the plot is in the right place"
                       (nth (@model :coefs) 0) => (roughly 0 ?accuracy0)
                       (nth (@model :coefs) 1) => (roughly example-a-slope ?accuracy1))

                 (fact "the plot is not too wobbly"
                       (@model :r-square) => #(> % ?r-square)))))))

  ?type   ?state-step ?time-step ?max-fun-evals ?tol-fun ?accuracy0 ?accuracy1 ?r-square
  :matlab 0.01        0.02       100            1e-6     0.01       0.01       0.999
  :matlab 0.01        0.02       400            1e-12    2e-3       5e-3       0.99999
  :matlab 0.001       0.002      400            1e-12    2e-4       2e-3       0.9999999
  ;; NB. these octave tests fail because the policy rule has jags (why?)
  :octave 0.01        0.02       100            1e-6     0.1        0.1        0.7
  :octave 0.01        0.02       400            1e-12    0.1        0.1        0.7))

(fact-group
 :fisheries-det-basic
 (tabular
  (with-state-changes [(before :facts (set-lab-type ?type))]

    (facts "about the fisheries control policy"
           (with-paths @lab ["tests/fisheries_det_basic"]

             ;; Call this once per table row so as to save time
             (util/call-fn-with-basic-vals @lab 0 0 :solve [?states] [?time-step])

             ;; Run simulations on the controls from viable starting
             ;; points and check that they arrive the steady-state
             ;; position that produces the greatest profit
             (let [final (-> @lab
                             (util/call-fn-with-basic-vals 0 1 :sim_final ?start [?steps])
                             first
                             vec)
                   steady-one (->> final
                                   matrix
                                   (mmult (matrix [[1/600 5/4]]))
                                   first)]

               (if ?steady
                 (fact "Simulations starting from viable starting points arrive at a steady state"
                       steady-one => (roughly 1.0 ?steady-accuracy))

                 (fact "Simulations starting from non-viable starting points do not arrive at a steady state"
                       steady-one =not=> (roughly 1.0 ?steady-accuracy)))

               (doall
                (map (fn my-fn [actual expected accuracy]
                       (if ?steady
                         (fact "Simulations starting from viable starting points approximate the optimal point"
                               actual => (roughly expected accuracy))

                         (fact "Simulations starting from non-viable starting points do not approximate the optimal point"
                               actual =not=> (roughly expected accuracy))))
                     final
                     fisheries-profix-max-steady
                     ?optim-accuracy))))))

  ?type   ?states ?time-step ?start    ?steps ?steady ?steady-accuracy ?optim-accuracy
  :matlab 10      1          [100 0.5] 100    true    0.001            [5   0.1]
  :matlab 20      0.5        [600 0.6] 200    true    0.001            [5  0.05]
  :matlab 40      0.25       [60  0.1] 300    true    0.001            [6  0.03]
  :matlab 10      1          [600 1.0] 200    false   0.001            [5   0.1]
  :octave 10      1          [100 0.5] 100    true    0.001            [5   0.1]
  :octave 20      0.5        [600 0.6] 200    true    0.001            [5  0.05]))
