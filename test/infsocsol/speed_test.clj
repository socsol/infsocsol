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

(ns infsocsol.speed-test
  (:use infsocsol.core
        (incanter core stats charts))
  (:require [profile.core :as p]
            [cljlab.core :as cl]
            [cljlab.util :as util]))

(defn example-a-current [cpus states]
  (with-paths @lab ["tests/example_a_speed"]
    (-> (util/call-fn-with-basic-vals @lab 0 1 :solve_current [cpus] [states])
        first
        first
        int)))

(defn example-a-v2 [states]
  (in-path @lab "tests/example_a_speed"
    (-> (util/call-fn-with-basic-vals @lab 0 1 :solve_v2 [states])
        first
        first
        int)))

(defn fisheries-det-basic-current [cpus states time-step]
  (with-paths @lab ["tests/fisheries_det_basic_speed"]
    (-> (util/call-fn-with-basic-vals @lab 0 1 :solve_current
                                      [cpus]
                                      [states]
                                      [time-step])
        first
        first
        int)))

(defn fisheries-det-basic-v2 [states time-step]
  (in-path @lab "tests/fisheries_det_basic_speed"
    (-> (util/call-fn-with-basic-vals @lab 0 1 :solve_v2
                                      [states]
                                      [time-step])
        first
        first
        int)))


(defmacro profile [func & forms]
  `(try
     (p/profile-var ~func)
     (p/with-session {:max-sample-count 1}
       (let [iterations# (do ~@forms)]
         {:iterations iterations#
          :profile (p/summary)}))
     (finally (p/unprofile-var ~func))))

(defmacro run-profile [platform data & body]
  `(do
     (set-lab-type ~platform)
     (util/call-fn-with-basic-vals @lab 0 0 :disp (name ~platform))
     (merge ~data
            (let [res# (do ~@body)]
              {:platform ~platform
               :time (-> (res# :profile)
                         (get :stats)
                         first
                         (get :mean)
                         (/ 1e9))
               :iterations (res# :iterations)}))))

(defn profile-example-a
  "Profiling of example A"
  [samples]
  (dataset
   [:platform :version :cpus :states :iterations :time]
   (doall
    (apply concat
           (for [states (concat (range 51 501 (/ (- 501 51) (- samples 1))) [501])]

             (conj
              (for [platform [:matlab :octave]
                    cpus (range 1 5)]

                (run-profile platform
                             {:version :current
                              :cpus cpus
                              :states states}
                             (profile example-a-current
                                      (example-a-current cpus states))))

              (run-profile :matlab
                           {:version :v2
                            :cpus 1
                            :states states}
                           (profile example-a-v2
                                    (example-a-v2 states)))))))))

(defn profile-fisheries-det-basic
  "Profiling of basic deterministic fisheries model"
  [samples]
  (dataset
   [:platform :version :cpus :states :iterations :time]
   (doall
    (apply concat
           (for [i (range 0 samples)
                 :let [states (* (Math/pow 2 i) 10)
                       time-step (/ 1 (Math/pow 2 i))]]
             (conj
              (for [platform [:matlab :octave]
                    cpus (range 1 5)]

                (run-profile platform
                             {:version :current
                              :cpus cpus
                              :states states}
                             (profile fisheries-det-basic-current
                                      (fisheries-det-basic-current cpus states time-step))))

              (run-profile :matlab
                           {:version :v2
                            :cpus 1
                            :states states}
                           (profile fisheries-det-basic-v2
                                    (fisheries-det-basic-v2 states time-step)))))))))


(defn plot-profiles [x-label y-label data]
  (let [groups (->> data
                    ($order [:version :platform :cpus] :asc)
                    ($group-by [:cpus :version :platform]))
        plot-lines (fn [plot [h d i]]
                     (with-data d
                       (try
                         (add-lines plot x-label y-label :series-label (str h))
                         (finally (set-stroke-color plot
                                                    (java.awt.Color. ;; red, green, blue
                                                     (/ (h :cpus) 4.0)
                                                     (if (= (h :platform) :matlab) 0.0 0.5)
                                                     (if (= (h :version) :current) 0.0 0.5))
                                                    :dataset (inc i))))))]
     (reduce plot-lines
             (xy-plot [] []
                      :legend true
                      :x-label (name x-label)
                      :y-label (name y-label)
                      :series-label "")
             (map conj groups (range 0 (count groups))))))
