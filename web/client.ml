open Js_of_ocaml

let to_image_data : Brr_canvas.C2d.Image_data.t -> Dom_html.imageData Js.t =
  (* TODO eliminate either Brr or jsoo's standard library *)
  Obj.magic

let () =
  let d = Aruco.(detector ~dict:aruco_mip_36h12 ()) in
  let module M = Brr_io.Media in
  Fut.await (
    let ds = M.Devices.of_navigator Brr.G.navigator in
    M.Devices.get_user_media ds (M.Stream.Constraints.(v ~video:(`Yes None) ()))
  ) @@ function
    | Error e ->
      prerr_endline (Jstr.to_string (Jv.Error.message e))
    | Ok stream ->
      let v = Brr.El.video [] in
      let vm = M.El.of_el v in
      M.El.set_auto_play vm true;
      M.El.(set_src_object vm (Some (Provider.of_media_stream stream)));
      let w, h = 400, 300 in
      let module C = Brr_canvas in
      let c = C.Canvas.create ~w ~h [] in
      let ctx = C.C2d.get_context c in
      let rec f _tick =
        ignore (Brr.G.request_animation_frame f);
        if M.El.(ready_state vm = Have.enought_data) then (
          C.C2d.(draw_image ctx (image_src_of_el v) ~x:0. ~y:0.);
          let data = C.C2d.get_image_data ~x:0 ~y:0 ~w ~h ctx in
          Js.to_array (d##detect (to_image_data data)) |> Array.iter @@ fun m ->
            let c = Js.to_array m##.corners in
            let module P = C.C2d.Path in
            let p = P.create () in
            P.move_to p ~x:(float c.(0)##.x) ~y:(float c.(0)##.y);
            for i = 1 to Array.length c - 1 do
              P.line_to p ~x:(float c.(i)##.x) ~y:(float c.(i)##.y)
            done;
            P.close p;
            C.C2d.set_stroke_style ctx (C.C2d.color (Jstr.of_string "red"));
            C.C2d.stroke ctx p;
            C.C2d.stroke_text ctx
              (Jstr.of_string (string_of_int m##.id))
              ~x:(float c.(0)##.x)
              ~y:(float c.(0)##.y)
        )
      in
      let pause = Brr.El.button [Brr.El.txt (Jstr.of_string "pause")] in
      let toggle _ =
        if M.El.paused vm then ignore (M.El.play vm)
        else M.El.pause vm
      in
      ignore (Brr.Ev.(listen click) toggle (Brr.El.as_target pause));
      Brr.El.append_children (Brr.Document.body Brr.G.document) [
        pause;
        C.Canvas.to_el c
      ];
      ignore (Brr.G.request_animation_frame f)
