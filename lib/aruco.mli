open Js_of_ocaml

class type corner = object
  method x : int Js.readonly_prop
  method y : int Js.readonly_prop
end

class type marker = object
  method id : int Js.readonly_prop
  method corners : corner Js.t Js.js_array Js.t Js.readonly_prop
  method hamming_distance : float Js.readonly_prop
end

class type detector = object
  method detect : Dom_html.imageData Js.t -> marker Js.t Js.js_array Js.t Js.meth
end

type dict_name
val aruco : dict_name
val aruco_mip_36h12 : dict_name

val detector : ?dict:dict_name -> ?max_hamming_dist:int -> unit -> detector Js.t

class type dictionary = object
  method generateSVG : int -> Js.js_string Js.t Js.meth
end

val dictionary : (dict_name -> dictionary Js.t) Js.constr
