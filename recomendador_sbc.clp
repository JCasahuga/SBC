
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
  (assert (nuevoUsuario))
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

; ////////////////////             QUESTIONS                  ///////////////////////////

(defrule p_nombre "Pregunta el nombre"
  (nuevoUsuario)
  ?x <- (object(is-a Persona))
  =>
  (printout t "Como se llama usted?" crlf)
  (bind ?nombre (read))
  (send ?x put-nombre ?nombre)
)

(defrule p_edad "Pregunta la edad"
  (nuevoUsuario)
  ?x <- (object(is-a Persona))
  =>
  (printout t "Que edad tiene usted?" crlf)
  (bind ?edad (read))
  (while (not(and(>= ?edad 65)(<= ?edad 110))) do
    (printout t "Edad no valida: Vuelva a introducirla, por favor." crlf)
    (bind ?edad (read))
  )
  (send ?x put-edad ?edad)
)

(defrule p_altura "Pregunta la altura"
  (nuevoUsuario)
  ?x <- (object(is-a Persona))
  =>
  (printout t "Que altura tiene usted? (en cm)" crlf)
  (bind ?altura (read))
  (while (<= ?altura 0) do
    (printout t "Altura no valida: Vuelva a introducirla, por favor." crlf)
    (bind ?altura (read))
  )
  (send ?x put-altura ?altura)
)

(defrule p_peso "Pregunta el peso"
  (nuevoUsuario)
  ?x <- (object(is-a Persona))
  =>
  (printout t "Que peso tiene usted? (en kg)" crlf)
  (bind ?peso (read))
  (while (<= ?peso 0) do
    (printout t "peso no valido: Vuelva a introducirlo, por favor." crlf)
    (bind ?peso (read))
  )
  (send ?x put-peso ?peso)
)

;Nivel de actividad no definido en la ontología (al menos yo no lo he visto xd)
;(defrule p_nivel_actividad "Pregunta el nivel de actividad"
;  (nuevoUsuario)
;  ?x <- (object(is-a Persona))
;  =>
;  (printout t "Cuan activo/a es usted? (0:Sedentario, 1:Un poco activo/a, 2:Muy activo/a)" crlf)
;  (bind ?actividad (read))
;  (while (not (and(>= ?actividad 0)(<= ?actividad 2))) do
;    (printout t "Nivel de actividad no valido: Vuelva a introducirlo, por favor." crlf)
;    (bind ?actividad (read))
;  )
;  (send ?x put-actividad ?actividad)
;)
