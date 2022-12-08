
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
	(printout t "**************************************************************************************************************"crlf)
	(printout t "*                                          AUTO DIAGNOSTIC                                                   *"crlf)
	(printout t "*                      Bienvenido al recomendador de ejercicios para personas mayores!             					*"crlf)
	(printout t "**************************************************************************************************************"crlf)
	(printout t crlf crlf)
	(printout t crlf crlf)
	(printout t "")
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
   (bind ?response (ask-question ?question si no s n Si No))
   (if (or (eq ?response si) (eq ?response s) (eq ?response Si))
       then TRUE
       else FALSE)
)

; Asks a question which has to be answered with a numberic value wchich must be >= than the given one.
(deffunction question-numeric-bigger (?question ?lowerbound)
  (printout t ?question)
	(bind ?respuesta (read))
	(while (< ?respuesta ?lowerbound) do
		(format t "Porfavor, introduzca un valor mayor o igual que %d: " ?lowerbound)
		(bind ?respuesta (read))
	)
	?respuesta
)

; Asks a question which has to be answered with a numberic value within the given range.
(deffunction question-numeric-range (?question ?rangini ?rangfi)
	(format t "%s [%d, %d]: " ?question ?rangini ?rangfi)
	(bind ?respuesta (read))
	(while (not(and(>= ?respuesta ?rangini)(<= ?respuesta ?rangfi))) do
		(format t "Porfavor, introduzca un valor entre %d i %d: " ?rangini ?rangfi)
		(bind ?respuesta (read))
	)
	?respuesta
)



; ////////////////////             QUESTIONS                  ///////////////////////////

(defrule p_nombre "Pregunta el nombre"
  (nuevoUsuario)
  ?p <- (object(is-a Persona))
  =>
  (printout t "Como se llama usted?" crlf)
  (bind ?nombre (read))
  (send ?p put-nombre ?nombre)
)

(defrule p_edad "Pregunta la edad"
  (nuevoUsuario)
  ?p <- (object(is-a Persona))
  =>
  (bind ?edad (question-numeric-bigger "Que edad tiene usted? (este programa solo hace recomendaciones para mayores de 65 años): " 65))
  (send ?p put-edad ?edad)
)

(defrule p_altura "Pregunta la altura"
  (nuevoUsuario)
  ?p <- (object(is-a Persona))
  =>
  (bind ?altura (question-numeric-bigger "Introduzca su altura en centímetros: " 0))
  (send ?p put-altura ?altura)
)

(defrule p_peso "Pregunta el peso"
  (nuevoUsuario)
  ?p <- (object(is-a Persona))
  =>
  (bind ?altura (question-numeric-bigger "Introduzca su peso en kg: " 0))
  (send ?p put-altura ?altura)
)

;Nivel de actividad no definido en la ontología (al menos yo no lo he visto xd)
;(defrule p_nivel_actividad "Pregunta el nivel de actividad"
;  (nuevoUsuario)
;  ?p <- (object(is-a Persona))
;  =>
;  (printout t "Cuan activo/a es usted? (0:Sedentario, 1:Un poco activo/a, 2:Muy activo/a)" crlf)
;  (bind ?actividad (read))
;  (while (not (and(>= ?actividad 0)(<= ?actividad 2))) do
;    (printout t "Nivel de actividad no valido: Vuelva a introducirlo, por favor." crlf)
;    (bind ?actividad (read))
;  )
;  (send ?p put-actividad ?actividad)
;)

(defrule p_corazon "Pregunta problemas del corazón"
	(nuevoUsuario)
	?p <- (object(is-a Persona))
	=>
	(bind ?ans (yes-or-no-p "Ha padecido (o padece) problemas del corazón? (si/no): "))
	(if (eq ?ans TRUE) then
		; TODO: no se com podem guardar per indicar-ho
    (bind ?ans (yes-or-no-p "Tiene usted hipertensión? (si/no): "))
    ;(send ?p put-edad ?ans)
	)
)

(defrule p_mobilidad "Pregunta por partes del cuerpo con problemas de mobilidad"
	(nuevoUsuario)
	?p <- (object(is-a Persona))
	=>
	(bind ?ans (yes-or-no-p "Sufre algun problema de mobilidad? (si/no): "))
	(if (eq ?ans TRUE) then
    (bind ?quedan-partes TRUE)
    (while (eq ?quedan-partes TRUE) do 
    	(bind ?parte (ask-question "En que parte del cuerpo sufre problemas? " Brazos brazos Brazo brazo Cadera cadera Cuello cuello Hombros hombros Hombro hombro Lumbar lumbar Espalda espalda Manos manos Mano mano Muñecas muñecas Muñeca muñeca Piernas piernas Pierna pierna Pies pies Pie pie Tobillos tobillos Tobillo tobillo)) ;Could be extended with Rodillas rodillas Rodilla rodilla Pecho pecho Dedos dedos Dedo dedo Pantorrilla pantorrilla Cintura cintura 
      ; TODO: no se com podem guardar per indicar-ho en el filtratge
      (bind ?quedan-partes (yes-or-no-p "Tienes más partes del cuerpo con problemas de mobilidad? (si/no): "))
    )
	)
)

(defrule p_diabetes "Pregunta por diabetes"
  (nuevoUsuario)
  ?p <- (object(is-a Persona))
  =>
  (bind ?ans (yes-or-no-p "Tiene usted diabetes? (si/no): "))
  ;(send ?p put-edad ?ans)
)


(defrule p_psicologicos "Pregunta por problemas psicologicos"
	(nuevoUsuario)
	?p <- (object(is-a Persona))
	=>
	(bind ?ans (yes-or-no-p "Ha sido diagnosticado de alguna enfermedad psicologica? (si/no): "))
	(if (eq ?ans TRUE) then
		; TODO: no se com podem guardar per indicar-ho
    (bind ?ans (yes-or-no-p "Sufre usted ansiedad? (si/no): "))
    (bind ?ans (yes-or-no-p "Sufre usted depresión? (si/no): "))
    (bind ?ans (yes-or-no-p "Sufre usted estrés? (si/no): "))
    (bind ?ans (yes-or-no-p "Sufre usted insomnio? (si/no): "))
	)
)

(defrule p_cancer "Pregunta por cáncer"
  (nuevoUsuario)
  ?p <- (object(is-a Persona))
  =>
  (bind ?ans (yes-or-no-p "Sufre (o ha sufrido) usted cáncer? (si/no): "))
  ;(send ?p put-edad ?ans)
)

(defrule p_disponibilidad "Pregunta por la disponibilidad"
	(nuevoUsuario)
  ?p <- (object(is-a Persona))
	=>
	(bind ?ans (ask-question "Cuantos días a la semana podria relizar el programa personalizado? " 0 1 2 3 4 5 6 7))
	(if (< ?ans 3) then 
    (printout t crlf "Lo sentimos, no podemos organizar un plan de entrenamiento para menos de 3 días por semana." crlf)
    (printout t "Le recomendamos que vuelva a consultar un plan personalizado cuando disponga de ellos, grácias." crlf)
    (halt)
	)
)

(defmodule RESULT
	(import MAIN ?ALL)
	(import QUESTIONS ?ALL)
  (export ?ALL)
)
