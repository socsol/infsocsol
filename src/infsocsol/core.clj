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

(ns infsocsol.core
  (:require [cljlab.core :as cl]
            [cljlab.util :as util]))

(def lab (atom nil))

(defn set-lab-type
  "Makes sure the lab atom is of the correct type"
  [type]
  (if (or (nil? @lab)
          (not= (cl/type @lab) type)
          (not (cl/open? @lab)))
    (do
      (if @lab (cl/exit @lab))
      (reset! lab (cl/open {:type type :out *out*})))))

(defmacro with-paths
  "evaluates a form with a given set of paths the lab's search-path"
  [lab paths & forms]
  `(do (dorun (map #(util/call-fn-with-basic-vals ~lab 0 0 :addpath %) ~paths))
       (try
         (do ~@forms)
         (finally
           (dorun (map #(util/call-fn-with-basic-vals ~lab 0 0 :rmpath %) ~paths))))))

(defmacro in-path
  "evaluates a form inside a given path"
  [lab path & forms]
  `(let [old-path# (first (util/call-fn-with-basic-vals ~lab 0 1 :pwd))]
     (util/call-fn-with-basic-vals ~lab 0 0 :cd ~path)
     (try
       (do ~@forms)
       (finally
         (util/call-fn-with-basic-vals ~lab 0 0 :cd old-path#)))))

(defmacro with-plots
  "evaluates forms and closes all open handles afterwards"
  [lab & forms]
  `(let [return# (do ~@forms)]
     (cl/eval ~lab "close all hidden")
     return#))
