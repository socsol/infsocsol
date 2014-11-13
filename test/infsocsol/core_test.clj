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

(defn set-lab-type
  "Makes sure the lab atom is of the correct type"
  [type]
  (if (or (nil? @lab)
          (not= (cl/type @lab) type)
          (not (cl/open? @lab)))
    (do
      (if @lab (cl/exit @lab))
      (reset! lab (cl/open {:type type}))
      (cl/eval @lab "diary infsocsol.core-test.log"))))

(defmacro with-paths
  "evaluates a form with a given set of paths the lab's search-path"
  [lab paths & forms]
  `(do (doall (map #(util/call-fn-with-basic-vals ~lab 0 0 :addpath %) ~paths))
       (let [return# (do ~@forms)]
         (doall (map #(util/call-fn-with-basic-vals ~lab 0 0 :rmpath %) ~paths))
         return#)))

(defmacro with-plots
  "evaluates a form and closes all open handles afterwards"
  [lab & forms]
  `(do (let [return# (do ~@forms)]
         (cl/eval ~lab "close all")
         return#)))


 (fact-group
  :polimp
  (tabular
   (with-state-changes [(before :facts (set-lab-type ?type))
                        (around :facts (with-paths @lab ["tests/example_a_polimp"] ?form))]

     (fact "the policy improvement algorithm can produce the same policies as in InfSOCSol2"

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
                         (range (nth dims 1)))))))

   ?type    ?state-step ?time-step ?max-fun-evals ?tol-fun  ?file
   :matlab  0.01        0.02       400            1e-12     "example_a51_policies.mat"
   :matlab  0.001       0.002      400            1e-12     "example_a501_policies.mat"))

(fact-group
 :example-a
 (tabular
  (with-state-changes [(before :facts (set-lab-type ?type))
                       (around :facts (with-paths @lab ["tests/example_a"] ?form))]
    (facts "about the control function"
           (with-state-changes
             [(before :facts
                      (util/call-fn-with-basic-vals @lab 0 0 :solve
                                                    [?state-step]
                                                    [?time-step]
                                                    [?max-fun-evals]
                                                    [?tol-fun]))]

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
                          (reset! model (linear-model (matrix (cl/get @lab :controls))
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
  (with-state-changes [(before :facts (set-lab-type ?type))
                       (around :facts (with-paths @lab ["tests/fisheries_det_basic"] ?form))]

    (facts "about the control function"
           (with-state-changes
             [(before :facts
                      (util/call-fn-with-basic-vals @lab 0 0 :solve
                                                    [?states]
                                                    [?time-step]
                                                    [?max-fun-evals]
                                                    [?tol-fun]))]

             ;; Check that the plot actually appears
             (fact "it plots without errors"
                   (with-plots @lab
                     (util/call-fn-with-basic-vals @lab 0 0 :iss_plot_contrule
                                                   "fisheries_det_basic"
                                                   [500.0 0.0]
                                                   "VariableOfInterest"
                                                   [2])
                     (first (util/call-fn-with-basic-vals @lab 0 1 :gcf))) =not=> empty?)

             ;; Here we run the plot, but make sure it is closed
             (let [controls (with-plots @lab
                              (-> @lab
                                  (util/call-fn-with-basic-vals 0 1 :iss_plot_contrule
                                                                "fisheries_det_basic"
                                                                [500.0 0.0]
                                                                "VariableOfInterest"
                                                                [2])
                                  first
                                  vec))]

               (fact "it returns a vector of controls"
                     controls => vector?)

               (fact "the control policy is always within bounds"
                     (doall (map #(% => (roughly 0 0.01))
                                 controls)))))))

  ?type   ?states ?time-step ?max-fun-evals ?tol-fun
  :matlab 10      1          100            1e-6
  :matlab 20      1          400            1e-12
  :matlab 50      1          400            1e-12
  :octave 10      1          100            1e-6
  :octave 20      1          400            1e-12))
