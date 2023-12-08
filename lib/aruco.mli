open Js_of_ocaml

class type corner = object
  method x : int Js.readonly_prop
  method y : int Js.readonly_prop
end

class type marker = object
  method id : int Js.readonly_prop
  method corners : corner Js.t Js.js_array Js.t Js.readonly_prop
  method hamming_distance : int Js.readonly_prop
end

class type detector = object
  method detect : Dom_html.imageData Js.t -> marker Js.t Js.js_array Js.t Js.meth
end

type dict_name

val aruco : dict_name
(** 7x7 marker with 25-bit information,
    minimum Hamming distance between any two codes = 3 and 1023 codes. *)

val aruco_mip_36h12 : dict_name
(** 8x8 marker with 36-bit information,
    minimum Hamming distance between any two codes = 12 and 250 codes. *)

val detector : ?dict:dict_name -> ?max_hamming_dist:int -> unit -> detector Js.t
(** Create an [AR.Detector] object using a specific dictionary
    (by default, [aruco_mip_36h12]).
    You may specify a custom maximum Hamming distance instead of its [tau].
    Using a smaller value makes the detection more reliable on high-res images,
    at the cost of skipping possible relevant markers in low-res images. *)

class type dictionary = object
  method codeList : int Js.js_array Js.t Js.readonly_prop

  method tau : int Js.readonly_prop
  (** Default maximum Hamming distance *)

  method generateSVG : int -> Js.js_string Js.t Js.meth
  (** Valid ids are between 0 and [codeList##.length-1] *)
end

val dictionary : (dict_name -> dictionary Js.t) Js.constr
