
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
	(printout t "*                      Bienvenido al recomendador de ejercicios para personas mayores!                       *"crlf)
	(printout t "**************************************************************************************************************"crlf)
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
   (bind ?response (ask-question ?question si no s n Si No y Yes Y S s))
   (if (or (eq ?response si) (eq ?response s) (eq ?response Si) (eq ?response Yes) (eq ?response Y) (eq ?response y))
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
  (send ?p put-peso ?altura)
)

(defrule p_nivel_actividad "Pregunta el nivel de actividad"
  (nuevoUsuario)
  ?p <- (object(is-a Persona))
  =>
  (bind ?actividad (question-numeric-range "Ponga un número del 1 al 5 que represente su nivel de actividad (1: Nada activo, 5: Muy activo)" 1 5))
  (send ?p put-nivel_fisico ?actividad)
)

(defrule p_corazon "Pregunta problemas del corazón"
	(nuevoUsuario)
	?p <- (object(is-a Persona))
  ;?cardiopatia <- (object(is-a Cardiorespiratoria))
	=>
	(bind ?ans (yes-or-no-p "Ha padecido (o padece) problemas del corazón? (si/no): "))
	(if (eq ?ans TRUE) then
		(slot-insert$ [Jubilado] sufre 1 [Cardiopatía])
    (bind ?ans (yes-or-no-p "Tiene usted hipertensión? (si/no): "))
    (if (eq ?ans TRUE) then (slot-insert$ [Jubilado] sufre 1 [Hipertensión]))
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
      (if (or (eq (lowcase ?parte) brazo) (eq (lowcase ?parte) brazos)) then
        (slot-insert$ [Jubilado] sufre 1 [Brazos])
      )
      (if (eq (lowcase ?parte) cadera) then 
        (slot-insert$ [Jubilado] sufre 1 [Cadera])
      )
      (if (or (eq (lowcase ?parte) cuello) (eq (lowcase ?parte) hombro) (eq (lowcase ?parte) hombros)) then 
        (slot-insert$ [Jubilado] sufre 1 [Cuello_Hombros])
      )
      (if (or (eq (lowcase ?parte) lumbar) (eq (lowcase ?parte) espalda)) then 
        (slot-insert$ [Jubilado] sufre 1 [Lumbar_Espalda])
      )
      (if (or (eq (lowcase ?parte) mano) (eq (lowcase ?parte) manos) (eq (lowcase ?parte) muñeca) (eq (lowcase ?parte) muñecas)) then
        (slot-insert$ [Jubilado] sufre 1 [Mano_Muñeca])
      )
      (if (or (eq (lowcase ?parte) pierna) (eq (lowcase ?parte) piernas)) then
        (slot-insert$ [Jubilado] sufre 1 [Piernas])
      )
      (if (or (eq (lowcase ?parte) pies) (eq (lowcase ?parte) pie) (eq (lowcase ?parte) tobillo) (eq (lowcase ?parte) tobillos)) then
        (slot-insert$ [Jubilado] sufre 1 [Pies_Tobillos])
      )
      (bind ?quedan-partes (yes-or-no-p "Tienes más partes del cuerpo con problemas de mobilidad? (si/no): "))
    )
	)
)

(defrule p_diabetes "Pregunta por diabetes"
  (nuevoUsuario)
  ?p <- (object(is-a Persona))
  =>
  (bind ?ans (yes-or-no-p "Tiene usted diabetes? (si/no): "))
  (if (eq ?ans TRUE) then (slot-insert$ [Jubilado] sufre 1 [Diabetes]))
)


(defrule p_psicologicos "Pregunta por problemas psicologicos"
	(nuevoUsuario)
	?p <- (object(is-a Persona))
	=>
	(bind ?ans (yes-or-no-p "Ha sido diagnosticado de alguna enfermedad psicologica? (si/no): "))
	(if (eq ?ans TRUE) then
    (bind ?ans (yes-or-no-p "Sufre usted ansiedad? (si/no): "))
    (if (eq ?ans TRUE) then (slot-insert$ [Jubilado] sufre 1 [Ansiedad]))
    (bind ?ans (yes-or-no-p "Sufre usted depresión? (si/no): "))
    (if (eq ?ans TRUE) then (slot-insert$ [Jubilado] sufre 1 [Depresión]))
    (bind ?ans (yes-or-no-p "Sufre usted estrés? (si/no): "))
    (if (eq ?ans TRUE) then (slot-insert$ [Jubilado] sufre 1 [Estrés]))
    (bind ?ans (yes-or-no-p "Sufre usted insomnio? (si/no): "))
    (if (eq ?ans TRUE) then (slot-insert$ [Jubilado] sufre 1 [Insomnio]))
	)
)

(defrule p_cancer "Pregunta por cáncer"
  (nuevoUsuario)
  ?p <- (object(is-a Persona))
  =>
  (bind ?ans (yes-or-no-p "Sufre (o ha sufrido) usted cáncer? (si/no): "))
  (if (eq ?ans TRUE) then (slot-insert$ [Jubilado] sufre 1 [Cáncer]))
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

(defrule imprimir "Imprime las enfermedades del jubilado"
  (nuevoUsuario)
  ?p <- (object(is-a Persona))
  =>
  (bind ?enfermedades (send ?p get-sufre))
  (loop-for-count (?i 1 (length$ $?enfermedades)) do
    (bind ?enfermedad (nth$ ?i $?enfermedades))
    (printout t "Pateix " ?enfermedad crlf)
  )
)

(defrule posibles_ejercicios "Llista posibles exercicis"
  (nuevoUsuario)
  ?p <- (object(is-a Persona))
  =>
  (bind ?ejercicios (send ?p get-puede_realizar))
  (loop-for-count (?i 1 (length$ $?ejercicios)) do
    (bind ?ejercicio (nth$ ?i $?ejercicios))
    (printout t "Exercici " ?ejercicio crlf)
  )
  ;(bind ?ejercicios (send ?p get-))
  ;(bind ?segons_plats (find-all-instances ((?plat Plat)) TRUE)
  ;(bind ?sintoma [Fuerza])
  ;(bind ?sintoma (find-all-instances ((?inst Sintoma)) (not (eq (member ?aux2 ?inst:Mejora_con) FALSE))))
  ;(bind ?sintoma (find-all-instances (Ejercicio) TRUE))

  ;(do-for-all-instances ((?ins Ejercicio)) TRUE
    ;(printout t ?ins)
  ;)
  ; (loop-for-count (?i 1 (length$ $?enfermedades)) do
    
  ; )
)
