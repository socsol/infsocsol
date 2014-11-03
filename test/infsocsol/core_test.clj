(ns infsocsol.core-test
  (:use midje.sweet)
  (:use [infsocsol.core]))

(def lab (atom nil))

(defn load-test [path]
  (cl/eval @lab (join ["addpath('" path "')"])))

(facts
 (with-state-changes [(before :facts (do (if-not (nil? @lab) (cl/exit @lab))
                                         (reset! lab (cl/open))
                                         (cl/eval @lab "addpath('.')")))
                      (after :facts (cl/exit @lab))]))
