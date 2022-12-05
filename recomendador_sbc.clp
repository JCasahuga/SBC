
(defrule create_initial_person_instance
  (declare (salience 10))
  =>
  (make-instance p of Persona)
)

(defmodule MAIN
	(export ?ALL)
)

;///////////////////////             INIT                    //////////////////////////

; Program startup
(defrule startup "Da la bienvenida al programa"
  (initial-fact)
  =>
	(printout t crlf crlf)
	(printout t "Bienvenido al recomendador de ejercicios para personas mayores!")
	(printout t crlf crlf)
	(focus QUESTIONS)
)



; We obtain the data needed from the user in order to create a personalized program based on their answers.
(defmodule QUESTIONS
	(import MAIN ?ALL)
	(export ?ALL)
)

; ////////////////////             QUESTIONS TYPES             ///////////////////////////

; Asks a question which has to be answered with one of the allowed values.
(deffunction ask-question (?question $?allowed_values)
   (printout t ?question)
   (bind ?answer (read))
   (if (lexemep ?answer)
       then (bind ?answer (lowcase ?answer)))
   (while (not (member ?answer ?allowed_values)) do
      (printout t ?question)
      (bind ?answer (read))
      (if (lexemep ?answer)
          then (bind ?answer (lowcase ?answer))))
   ?answer
)

; Asks a question which has to be answered with either yes or no.
(deffunction yes-or-no-p (?question)
   (bind ?response (ask-question ?question si no s n))
   (if (or (eq ?response si) (eq ?response s))
       then TRUE
       else FALSE)
)

; Asks a question which has to be answered with a numberic value within the given range.
(deffunction question-numeric (?question ?rangini ?rangfi)
	(format t "%s [%d, %d] " ?question ?rangini ?rangfi)
	(bind ?respuesta (read))
	(while (not(and(>= ?respuesta ?rangini)(<= ?respuesta ?rangfi))) do
		(format t " %s [%d, %d] " ?question ?rangini ?rangfi)
		(bind ?respuesta (read))
	)
	?respuesta
)