(*****************************************************************************)
(* The MIT License (MIT)                                                     *)
(*                                                                           *)
(* Copyright (c) 2015 Multilang                                              *)
(*  Loïc Runarvot <loic.runarvot[at]gmail.com>                               *)
(*                                                                           *)
(* Permission is hereby granted, free of charge, to any person obtaining a   *)
(* copy of this software and associated documentation files (the "Software"),*)
(* to deal in the Software without restriction, including without limitation *)
(* the rights to use, copy, modify, merge, publish, distribute, sublicense,  *)
(* and/or sell copies of the Software, and to permit persons to whom the     *)
(* Software is furnished to do so, subject to the following conditions:      *)
(*                                                                           *)
(* The above copyright notice and this permission notice shall be included   *)
(* in all copies or substantial portions of the Software.                    *)
(*                                                                           *)
(* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS   *)
(* OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF                *)
(* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.    *)
(* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY      *)
(* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT *)
(* OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR  *)
(* THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                *)
(*****************************************************************************)


module MultiLangMap = Map.Make(struct
    type t = string
    let compare = String.compare
  end)

type t = string MultiLangMap.t

let multilang_cache : (string, t) Hashtbl.t = Hashtbl.create 4
let add_cache = Hashtbl.add multilang_cache
let get_cache = Hashtbl.find multilang_cache
let exists_cache = Hashtbl.mem multilang_cache
let clear_cache () = Hashtbl.clear multilang_cache

(*

   Default configuration

 *)

let set ref_ val_ = ref_ := val_
let get ref_ ()   = !ref_

let __multilang_default_allow_duplication = ref false
let set_allow_duplication = set __multilang_default_allow_duplication
let allow_duplication = get __multilang_default_allow_duplication

let __multilang_default_base_folder = ref "lang"
let set_base_folder = set __multilang_default_base_folder
let base_folder = get __multilang_default_base_folder


(*
   
   Locale handling
   
 *)

exception Multilang_file_not_found of string

type locale =
  | Default
  | Partial of string
  | Complete of string * string

let make_locale base =
  let simple_split str char =
    try
      let index = String.index str char in
      let length = String.length str in
      String.sub str 0 index,
      String.sub str (index + 1) (length - index - 1)
    with Not_found ->
      (* String.index *)
      str, ""
  in
  let lang, _ = simple_split base '.' in
  let language, country = simple_split lang '_' in
  if country = "" then Partial language else Complete (language, country)

let make_filename where base locale =
  let mk = Printf.sprintf "_%s" in
  let l, c = match locale with
    | Default -> "", ""
    | Partial l -> mk l, ""
    | Complete (l, c) -> mk l, mk c
  in
  Filename.concat where (Printf.sprintf "%s%s%s.multilang" base l c)

let find_file where base locale =
  let down = function
    | Default -> raise (Multilang_file_not_found base)
    | Partial _ -> Default
    | Complete (s, _) -> Partial s
  in
  let rec aux locale =
    let filename = make_filename where base locale in
    if not (Sys.file_exists filename) || Sys.is_directory filename
       || not (Filename.check_suffix filename ".multilang") then
      aux (down locale)
    else
      filename
  in aux locale


(*

   Multilang implementation
   
*)

exception Duplication of string
exception Key_failure of string

let with_open_in filename handler =
  let channel = open_in filename in
  try
    let data = handler channel in
    close_in channel;
    data
  with exn ->
    close_in channel;
    raise exn

let make_multilang ?(where = base_folder ()) ?(locale = None) basename =
  let locale = match locale with
    | None ->
      begin try
          make_locale (Sys.getenv "LANG")
        with Not_found ->
          Default
      end
    | Some s ->
      make_locale s
  in
  let filename = find_file where basename locale in
  if exists_cache filename then
    get_cache filename
  else
    let map =
      with_open_in filename (fun channel ->
          Lexer.lex_until_none (Lexing.from_channel channel)
            (fun acc (id, text) ->
               if not (allow_duplication ()) && MultiLangMap.mem id acc then
                 raise (Duplication (Printf.sprintf "%s:%s" filename id));
               MultiLangMap.add id text acc) MultiLangMap.empty
        )
    in
    add_cache filename map;
    map

let key_exists multilang key = MultiLangMap.mem key multilang

let keys multilang = List.map fst (MultiLangMap.bindings multilang)

let get_value multilang key =
  try
    MultiLangMap.find key multilang
  with Not_found ->
    raise (Key_failure key)


(*

   Pretty printing

*)

let pp_locale fmt = function
  | Default ->
    Format.fprintf fmt "@[Default@]"
  | Partial lang ->
    Format.fprintf fmt "@[Partial @[%s@]@]" lang
  | Complete (lang, country) ->
    Format.fprintf fmt "@[Complete @[(%s, %s)@]@]" lang country

let pp_multilang fmt multilang =
  Format.fprintf fmt "@[<hov 2>{%t @ }@]@\n"
    (fun fmt ->
       List.iter (fun (x, y) -> Format.fprintf fmt "@ %s : \"%s\";" x y)
         (MultiLangMap.bindings multilang))


(*
Local Variables:
compile-command: "make -C .."
End:
*)
