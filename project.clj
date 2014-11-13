(defproject infsocsol "3.0.0-SNAPSHOT"
  :description "A suite of MATLAB routines devised to provide an approximately optimal solution to an infinite-horizon stochastic optimal control problem"
  :url "http://socsol.github.io/infsocsol/"
  :scm {:name "git" :url "https://github.com/socsol/infsocsol"}
  :license {:name "Apache Licence, Version 2.0"
            :url "http://www.apache.org/licenses/LICENSE-2.0.html"}
  :dependencies [[org.clojure/clojure "1.5.1"]
                 [cljlab "0.2.0"]]
  :profiles {:dev {:dependencies [[midje "1.6.3"]
                                  [incanter "1.5.5"]]}})
