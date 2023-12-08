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

type dict_name = Js.js_string Js.t
let aruco = Js.string "ARUCO"
let aruco_mip_36h12 = Js.string "ARUCO_MIP_36h12"

let ar = Js.Unsafe.global##._AR

(*
class type config = object
  method dictionary_name : dict_name Js.prop
  method max_hamming_distance : int Js.prop
end
*)

let detector ?(dict=aruco_mip_36h12) ?max_hamming_dist () =
  let ctor : (_ Js.t -> detector Js.t) Js.constr = ar##._Detector in
  new%js ctor (object%js
    val dictionary_name = Js.Opt.return dict
    val max_hamming_distance = Js.Opt.option max_hamming_dist
  end)

class type dictionary = object
  method codeList : int Js.js_array Js.t Js.readonly_prop
  method tau : int Js.readonly_prop
  method generateSVG : int -> Js.js_string Js.t Js.meth
end

let dictionary = ar##._Dictionary
