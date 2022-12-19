
(defmodule MAIN
	(export ?ALL)
)

;///////////////////////             INIT                    //////////////////////////

; Program startup
(defrule startup "Da la bienvenida al programa"
  (initial-fact)
  =>
  (printout t crlf crlf)
	(printout t "|============================================================================================================|"crlf)
	(printout t "|                                          AUTO DIAGNOSTIC                                                   |"crlf)
	(printout t "|                      Bienvenido al recomendador de ejercicios para personas mayores!                       |"crlf)
	(printout t "|============================================================================================================|"crlf)
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
   (printout t crlf ?question crlf "| > ")
   (bind ?answer (read))
   (if (lexemep ?answer)
       then (bind ?answer (lowcase ?answer)))
   (while (not (member ?answer ?allowed_values)) do
      (printout t "Lo sentimos pero no le hemos ententido, vuelva a escribir la respuesta." crlf "| > ")
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
  (printout t crlf ?question crlf "| > ")
	(bind ?respuesta (read))
	(while (< ?respuesta ?lowerbound) do
    (format t "Porfavor, introduzca un valor mayor o igual que %d." ?lowerbound)
    (printout t crlf "| > ")
		(bind ?respuesta (read))
	)
	?respuesta
)

; Asks a question which has to be answered with a numberic value within the given range.
(deffunction question-numeric-range (?question ?rangini ?rangfi)
  (printout t crlf)
	(format t "%s [%d, %d]" ?question ?rangini ?rangfi)
  (printout t crlf "| > ")
	(bind ?respuesta (read))
	(while (not(and(>= ?respuesta ?rangini)(<= ?respuesta ?rangfi))) do
		(format t "Porfavor, introduzca un valor entre %d i %d." ?rangini ?rangfi)
    (printout t crlf "| > ")
		(bind ?respuesta (read))
	)
	?respuesta
)



; ////////////////////             QUESTIONS                  ///////////////////////////

(defrule p_nombre "Pregunta el nombre"
  (nuevoUsuario)
  ?p <- (object(is-a Persona))
  =>
  (printout t "| > Como se llama usted?" crlf "| > ")
  (bind ?nombre (read))
  (send ?p put-nombre ?nombre)
)

(defrule p_edad "Pregunta la edad"
  (nuevoUsuario)
  ?p <- (object(is-a Persona))
  =>
  (bind ?edad (question-numeric-range "| > Que edad tiene usted? (Este programa solo hace recomendaciones para mayores de 65 años)" 65 150))
  (send ?p put-edad ?edad)
)

(defrule p_altura "Pregunta la altura"
  (nuevoUsuario)
  ?p <- (object(is-a Persona))
  =>
  (bind ?altura (question-numeric-range "| > Introduzca su altura en centímetros." 50 225))
  (send ?p put-altura ?altura)
)

(defrule p_peso "Pregunta el peso"
  (nuevoUsuario)
  ?p <- (object(is-a Persona))
  =>
  (bind ?altura (question-numeric-range "| > Introduzca su peso en kg." 40 200))
  (send ?p put-peso ?altura)
)

(defrule p_nivel_actividad "Pregunta el nivel de actividad"
  (nuevoUsuario)
  ?p <- (object(is-a Persona))
  =>
  (bind ?actividad (question-numeric-range "| > Ponga un número del 1 al 5 que represente su nivel de actividad (1: Nada activo, 5: Muy activo)." 1 5))
  (send ?p put-nivel_fisico ?actividad)
)

(defrule p_borg "Pregunta escala de borg"
  (nuevoUsuario)
  ?p <- (object(is-a Persona))
  =>
  (bind ?borg (question-numeric-range "| > Después de caminar durante 15 minutos, indique del 1 al 10 como de agotado se siente (1: Como si nada, 10: Ya no puedo más)" 1 10))
  (send ?p put-borg ?borg)
)

(defrule p_corazon "Pregunta problemas del corazón"
	(nuevoUsuario)
	?p <- (object(is-a Persona))
  ;?cardiopatia <- (object(is-a Cardiorespiratoria))
	=>
	(bind ?ans (yes-or-no-p "| > Ha padecido (o padece) problemas del corazón? (si/no)."))
	(if (eq ?ans TRUE) then
		(slot-insert$ [Jubilado] sufre 1 [Cardiopatía])
    (bind ?ans (yes-or-no-p "| > Tiene usted hipertensión? (si/no): "))
    (if (eq ?ans TRUE) then (slot-insert$ [Jubilado] sufre 1 [Hipertensión]))
	)
)

(defrule p_mobilidad "Pregunta por partes del cuerpo con problemas de mobilidad"
	(nuevoUsuario)
	?p <- (object(is-a Persona))
	=>
	(bind ?ans (yes-or-no-p "| > Sufre algun problema de mobilidad? (si/no)."))
	(if (eq ?ans TRUE) then
    (bind ?quedan-partes TRUE)
    (while (eq ?quedan-partes TRUE) do 
    	(bind ?parte (ask-question "| > En que parte del cuerpo sufre problemas? " Brazos brazos Brazo brazo Cadera cadera Cuello cuello Hombros hombros Hombro hombro Lumbar lumbar Espalda espalda Manos manos Mano mano Muñecas muñecas Muñeca muñeca Piernas piernas Pierna pierna Pies pies Pie pie Tobillos tobillos Tobillo tobillo)) ;Could be extended with Rodillas rodillas Rodilla rodilla Pecho pecho Dedos dedos Dedo dedo Pantorrilla pantorrilla Cintura cintura 
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
      (bind ?quedan-partes (yes-or-no-p "| > Tienes más partes del cuerpo con problemas de mobilidad? (si/no)"))
    )
	)
)

(defrule p_diabetes "Pregunta por diabetes"
  (nuevoUsuario)
  ?p <- (object(is-a Persona))
  =>
  (bind ?ans (yes-or-no-p "| > Tiene usted diabetes? (si/no)"))
  (if (eq ?ans TRUE) then (slot-insert$ [Jubilado] sufre 1 [Diabetes]))
)


(defrule p_psicologicos "Pregunta por problemas psicologicos"
	(nuevoUsuario)
	?p <- (object(is-a Persona))
	=>
	(bind ?ans (yes-or-no-p "| > Ha sido diagnosticado de alguna enfermedad psicologica? (si/no)"))
	(if (eq ?ans TRUE) then
    (bind ?ans (yes-or-no-p "Sufre usted ansiedad? (si/no)"))
    (if (eq ?ans TRUE) then (slot-insert$ [Jubilado] sufre 1 [Ansiedad]))
    (bind ?ans (yes-or-no-p "Sufre usted depresión? (si/no)"))
    (if (eq ?ans TRUE) then (slot-insert$ [Jubilado] sufre 1 [Depresión]))
    (bind ?ans (yes-or-no-p "Sufre usted estrés? (si/no)"))
    (if (eq ?ans TRUE) then (slot-insert$ [Jubilado] sufre 1 [Estrés]))
    (bind ?ans (yes-or-no-p "Sufre usted insomnio? (si/no)"))
    (if (eq ?ans TRUE) then (slot-insert$ [Jubilado] sufre 1 [Insomnio]))
	)
)

(defrule p_cancer "Pregunta por cáncer"
  (nuevoUsuario)
  ?p <- (object(is-a Persona))
  =>
  (bind ?ans (yes-or-no-p "| > Sufre (o ha sufrido) usted cáncer? (si/no)"))
  (if (eq ?ans TRUE) then (slot-insert$ [Jubilado] sufre 1 [Cáncer]))
)

(defrule p_disponibilidad "Pregunta por la disponibilidad"
	(nuevoUsuario)
  ?p <- (object(is-a Persona))
	=>
	(bind ?ans (ask-question "| > Cuantos días a la semana podria relizar el programa personalizado? " 0 1 2 3 4 5 6 7))
	(if (< ?ans 3) then 
    (printout t crlf "Lo sentimos, no podemos organizar un plan de entrenamiento para menos de 3 días por semana." crlf)
    (printout t "Le recomendamos que vuelva a consultar un plan personalizado cuando disponga de ellos, grácias." crlf)
    (halt)
	)
  (send ?p put-dias_disponibles ?ans)
)

(defrule p_descripcion "Pregunta por requiere descripcion"
  (nuevoUsuario)
  ?p <- (object(is-a Persona))
  =>
  (bind ?descripcion (yes-or-no-p "| > Quiere recibir una descripción del conjunto de ejercicios? (si/no)"))
  (if (eq ?descripcion TRUE) 
    then (send ?p put-quiere_descripcion "true")
    else (send ?p put-quiere_descripcion "false")
  )
  (focus FILTRO_ENFERMEDADES)
)

;/////////////////////////////         FILTRO             /////////////////////////////////

(defmodule FILTRO_ENFERMEDADES
	(import MAIN ?ALL)
	(import QUESTIONS ?ALL)
	(export ?ALL)
)

(deffunction elimina-apariciones (?eje)
  (bind ?var (send [programa] get-contiene))
  (loop-for-count (?j 1 (length$ ?var)) do 
    (bind ?ejercicio_actual (nth$ ?j ?var))
    (if (eq ?ejercicio_actual ?eje) then
      (slot-delete$ [programa] contiene ?j ?j)
    )
  )
)

(defrule filtrar-mobilidad "Filtra aquellos ejercicios que no puede hacer por su mobilidad"
  (nuevoUsuario)
  ?p <- (object(is-a Persona))
  =>
  (bind ?nivel (send ?p get-nivel_fisico))
  (bind ?ejercicios (send ?p get-puede_realizar))

  (loop-for-count (?i 1 (length$ $?ejercicios)) do
     (bind ?ejercicio (nth$ ?i $?ejercicios))
     (slot-insert$ [programa] contiene 1 ?ejercicio)
  )
  (bind ?enfermedades (send ?p get-sufre))
	(loop-for-count (?i 1 (length$ $?enfermedades)) do
		(bind ?enfermedad (nth$ ?i $?enfermedades))

		(if (or (eq (class ?enfermedad) Mobilidad) (eq (class ?enfermedad) Partes_cuerpo)) then 
      (bind ?ejercicios_prohibidos (send ?enfermedad get-impide_hacer))
      (loop-for-count (?j 1 (length$ ?ejercicios_prohibidos)) do
        (bind ?ejercio_borrar (nth$ ?j ?ejercicios_prohibidos))
        (elimina-apariciones ?ejercio_borrar)
      )
		)
	)
)

(defrule filtrar-nivel "Filtra aquellos ejercicios que no puede hacer por su nivel"
  (nuevoUsuario)
  ?p <- (object(is-a Persona))
  =>
  (bind ?nivel (send ?p get-nivel_fisico))
  (bind ?ejercicios (send ?p get-puede_realizar))

  (loop-for-count (?i 1 (length$ $?ejercicios)) do
    (bind ?eje (nth$ ?i ?ejercicios))
    (bind ?nivel_ejercicio (send ?eje get-intensidad))
    (if (< (+ ?nivel 1) ?nivel_ejercicio) then
      (elimina-apariciones ?eje)
    )
  )
  (focus RESULTADO)
)

(defmodule RESULTADO
	(import MAIN ?ALL)
	(import QUESTIONS ?ALL)
  (import FILTRO_ENFERMEDADES ?ALL)
	(export ?ALL)
)

(deffunction calcula-reps-mins (?p ?act ?mult)
  (bind ?nivel (send ?p get-nivel_fisico))
  (bind ?intensidad (send ?act get-intensidad))
  (bind ?nivelBorg (send ?p get-borg))
  (bind ?rand (random))
  
  (bind ?nombre_act (send ?act get-nombre))
  (if (eq (class ?act) Resistencia) 
        then
          (printout t "|| Realize " ?nombre_act " durante ")
          (printout t (round (* ?mult (+ (+(/ (* (* ?nivel (- 6 ?intensidad)) (- 11 ?nivelBorg)) 5) 10) (mod ?rand 5)))))
          (printout t " minutos.")
        else
          (if (eq ?nombre_act "caminar") then (bind ?mult (* ?mult 1.4)))
          (printout t "|| Realize de " ?nombre_act " un total de ")
          (bind ?borgApartat (+ (/ (- 11 ?nivelBorg) 20) 0.65))
          (bind ?borgApartat (* ?borgApartat ?borgApartat))

          (bind ?nivelActApartat (+ (/ ?nivel 20) 0.9))

          (bind ?intensidadApartat (+ (/ (- 5 ?intensidad) 20) 0.9))
          (bind ?intensidadApartat (* ?intensidadApartat ?intensidadApartat))
          (bind ?final (* (* (* ?borgApartat ?intensidadApartat) ?nivelActApartat) 35))
          (bind ?final (* ?final (/ (+ (mod ?rand 3) 9) 10)))
          (printout t (round (* ?mult (- ?final (mod ?final 5)))))
          (printout t " repeticiones.")
  )
  (printout t crlf)
)

;Elimina el ejercicio ?eje de la instancia etapa
(deffunction elimina-ejercicio (?eje)
  (bind ?var (send [etapa] get-contiene))

  (loop-for-count (?j 1 (length$ ?var)) do 
    (bind ?ejercicio_actual (nth$ ?j ?var))
    (if (eq ?ejercicio_actual ?eje) then
      (slot-delete$ [etapa] contiene ?j ?j)
    )
  )
)

; Elimina los ejercicios que no cumplen las condiciones de etapa
; ?aerobico -> 0 no se trata, 1 se tratan
; ?calentamiento -> 0 no se trata, 1 se tratan
; La xor de ?aerobico i ?calentamiento deberia dar siempre true.
; ?negado -> 0 elimina las que no son X, 1 -> elimina las que son X
(deffunction elimina-ejercicios (?aerobico ?calentamiento ?negado)
  (bind ?var (send [etapa] get-contiene))

  (loop-for-count (?i 1 (length$ ?var)) do 
    (bind ?eje (nth$ ?i ?var))
    (if (eq ?aerobico 1)
      then 
      (if (eq ?negado 1) 
        then ; elimina no aerobicos
          (if (eq (send ?eje get-aerobico) "true") then (elimina-ejercicio ?eje))
        else ; elimina aerobicos
          (if (eq (send ?eje get-aerobico) "false") then (elimina-ejercicio ?eje))
      )
    )
    (if (eq ?calentamiento 1)
      then 
      (if (eq ?negado 1) 
        then ; elimina no aerobicos
          (if (eq (send ?eje get-calentamiento) "true") then (elimina-ejercicio ?eje))
        else ; elimina aerobicos
          (if (eq (send ?eje get-calentamiento) "false") then (elimina-ejercicio ?eje))
      )
    )
  )
)

; ?seleccion -> multislot con una lista de ejercicios a filtrar, 
; ?aerobico -> 0 si no importa, 1 si solo queremos aerobicos, 2 si solo queremos no aerobicos
; ?calentamiento -> 0 si no importa, 1 si solo queremos calentamientos, 2 si solo queremos no calentamientos
; se guarda en la instancia etapa
(deffunction obtener-subseleccion (?aerobico ?calentamiento)
  (if (> (length$ (send [etapa] get-contiene)) 0) 
    then (slot-delete$ [etapa] contiene 1 (max 1 (length$ (send [etapa] get-contiene))))
  )

  (bind ?seleccionado (send [programa] get-contiene))
  (loop-for-count (?i 1 (length$ $?seleccionado)) do
    (bind ?act_len (length$ (send [etapa] get-contiene)))
    (bind ?pos_random (+ 1 (mod (random) (max 1 ?act_len))))
    (bind ?act (nth$ ?i ?seleccionado))
    (slot-insert$ [etapa] contiene ?pos_random ?act)
  )
  
  (if (eq ?aerobico 1) 
    then (elimina-ejercicios 1 0 0)
    else (if (eq ?aerobico 2)
      then (elimina-ejercicios 1 0 1))
  )

  (if (eq ?calentamiento 1) 
    then (elimina-ejercicios 0 1 0)
    else (if (eq ?calentamiento 2)
      then (elimina-ejercicios 0 1 1))
  )

)

(deffunction suficientes-ejercicios ()
  (bind ?len_sel (length$ (send [programa] get-contiene)))
  (obtener-subseleccion 0 1)
  (bind ?len_sub1 (length$ (send [etapa] get-contiene)))
  (obtener-subseleccion 0 2)
  (bind ?len_sub2 (length$ (send [etapa] get-contiene)))
  (obtener-subseleccion 2 0)
  (bind ?len_sub3 (length$ (send [etapa] get-contiene)))

  (if (or (< ?len_sel 5) (< ?len_sub1 3) (< ?len_sub2 3) (< ?len_sub3 3))
    then 
    (printout t crlf "Lo sentimos, no podemos organizar un plan de entrenamiento dadas tus condiciones." crlf)
    (printout t "Le recomendamos que dencanse y se recupere, grácias." crlf)
    (halt)
    (exit)
  )
)


(defrule resultado_ejercicios "Lista posibles ejercicios"
  (nuevoUsuario)
  ?p <- (object(is-a Persona))
  =>
  (suficientes-ejercicios)

  (bind ?seleccionado (send [programa] get-contiene))
  (bind ?factor (+ (* (- (/ (send ?p get-altura) (* (send ?p get-peso) (send ?p get-edad))) 0.002) 7.5) 0.5))

  (printout t crlf " Processando informacion... " crlf)

  (printout t crlf " ################################## " crlf)
  (printout t " ========== Informacion =========== " crlf)
  (printout t " ################################## " crlf crlf)
  (printout t " Nombre:         " (send ?p get-nombre) crlf)
  (printout t " Edad:           " (send ?p get-edad) " años" crlf)
  (printout t " Altura:         " (send ?p get-altura) " cm"crlf)
  (printout t " Peso:           " (send ?p get-peso) " kg" crlf)
  (printout t " Factor:         " ?factor crlf)

  (printout t crlf " Processando programa... " crlf)

  (printout t crlf " ################################## " crlf)
  (printout t " =========== Programa ============= " crlf)
  (printout t " ################################## " crlf)

  (printout t crlf "|| Recomendamos realizar: " crlf)
  (bind ?dias_disponibles (send ?p get-dias_disponibles))
  (bind ?nivelM (send ?p get-nivel_fisico))
  (bind ?n_sesiones (max 3 (min (- ?dias_disponibles (- 4 (min ?nivelM 4))) 5)))
  (loop-for-count (?j 1 ?n_sesiones) do

    (bind ?day_type (mod ?j 2))
    ;(printout t ?day_type crlf)    
    
    (printout t "||" crlf "|==================================|" crlf)
    (printout t "|            SESSION " ?j "             |")
    (printout t crlf "|==================================|" crlf "||" crlf)

    (printout t "|| >>>>>>>> Calentamiento <<<<<<<< " crlf)

    (obtener-subseleccion 0 1)
    (bind ?subseleccion (send [etapa] get-contiene))

    (bind ?rand (random))
    (bind ?n_subseleccion (min (+ 2 (mod ?rand 2)) (length$ $?subseleccion)))

    (loop-for-count (?i 1 ?n_subseleccion) do
      (bind ?act (nth$ ?i ?subseleccion))
      (calcula-reps-mins ?p ?act (* ?factor 0.6))
    )

    (printout t "||" crlf "|| >>>>>>>> Entrenamiento <<<<<<<< " crlf)

    (obtener-subseleccion ?day_type 2)
    (bind ?subseleccion (send [etapa] get-contiene))

    (bind ?rand (random))
    (bind ?n_subseleccion (min (+ 1 (mod ?rand 1)) (length$ $?subseleccion)))

    (if (eq ?day_type 0) then (bind ?n_subseleccion (+ 2 ?n_subseleccion)))

    (loop-for-count (?i 1 ?n_subseleccion) do
      (bind ?act (nth$ ?i ?subseleccion))
      (calcula-reps-mins ?p ?act (* ?factor 1))
    )

    (printout t "||" crlf "|| >>>>>>>> Finalizacion <<<<<<<<< " crlf)

    (obtener-subseleccion 2 0)
    (bind ?subseleccion (send [etapa] get-contiene))

    (bind ?rand (random))
    (bind ?n_subseleccion (min (+ 2 (mod ?rand 2)) (length$ $?subseleccion)))

    (loop-for-count (?i 1 ?n_subseleccion) do
      (bind ?act (nth$ ?i ?subseleccion))
      (calcula-reps-mins ?p ?act (* ?factor 0.7))
    )
    (printout t "||" crlf)
  )
  (printout t "|==================================|" crlf "| " crlf)
  (bind ?dias_descanso (- ?dias_disponibles ?n_sesiones))
  (if (not (eq ?dias_descanso 0)) then 
    (printout t "| Le recomendamos que descanse " ?dias_descanso " de los " ?dias_disponibles " que dispone.")
  )
  (printout t crlf "| " crlf "| Recuerde también beber agua de forma abudante mientras realiza deporte." crlf "| " crlf)
  (printout t "|==================================|" crlf crlf)

  (bind ?descripcion (send ?p get-quiere_descripcion))
  (if (eq ?descripcion "true") then
    (printout t "-- Aquí tiene la lista de ejercicios y con su descripción:" crlf crlf)
    (loop-for-count (?i 1 (length$ ?seleccionado)) do
      (bind ?act (nth$ ?i ?seleccionado))
      (bind ?descripcion (send ?act get-descripcion))
      (printout t ?act ": " ?descripcion crlf crlf)
    )
  )
  (exit)
)