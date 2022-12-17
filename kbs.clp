

(defrule preguntar
    (declare (salience 20))
    ?p <- (object(is-a Persona))
    =>
    (printout t "Hello world!" crlf)
    (bind ?nombre (read))
    (send ?p put-nombre ?nombre)
    (printout t "Benvingut " (send ?p get-nombre) crlf)
)