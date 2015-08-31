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


(** Little module to handle different langage in the same program. *)


(** {2 Exception} *)

exception Duplication of string
(** [Duplication] is raised when two same keys exists in the multilang file.
    The string contains the filename, and the involved key. *)

exception Key_failure of string
(** [Key_failure] is raise when the key doesn't exists. The string contains
    the involved key. *)

exception Multilang_file_not_found of string
(** [Multilang_file_not_found] is raised when the multilang file is not found
    by the algorithm. The string contains the base name given. *)


(** {2 Default Configuration}
    Default value use by Multilang if no values are given. *)

val set_allow_duplication : bool -> unit
(** [set_allow_duplication b] set allow duplication to [b].
    By default the value is [false].

    If allow duplication is set to [false], then, during the lexing of the file,
    if the read key already exists, it raise the exception [Duplication].
*)

val allow_duplication : unit -> bool
(** [allow_duplication ()] check if duplication is allowed. *)

val set_base_folder : string -> unit
(** [set_base_folder base] change the default base folder *)

val base_folder : unit -> string
(** [base_folder ()] returns the base folder used when searching for an
    multilang file.

    The default value is ["lang"] *)



(** {2 Locale} *)

type locale =
  | Default
  (** Search the default file (no lang/country) *)
  | Partial of string
  (** Will search for files containing a lang *)
  | Complete of string * string
  (** Will search files containing lang & country *)
(** Type for parsed locale *)



(** {2 Multilang} *)

type t

val make_multilang : ?where:string -> ?locale:string option -> string -> t
(** [make_multilang ~where ~locale basename] will search for the multilang
    according to the three parameters. 

    The [~where] parameters is the folder from where the algorithm has to find
    the multilang file. By default, it uses the [base_folder ()] function
    (which as for default value "lang").

    The [~locale] parameters is to find which lang to use. If it sets to None,
    then it'll use the LANG environment value; but if LANG doesn't exists, it
    will search only the Default file. Othewerise, if [~locale] is set to
    Some string, it will be parse to be transformed into [locale] type.
    It must respect : "[[lang[_country[.encoding]]]]".

    The [basename] parameter is the basename used to find the file.

    The searched file will take the following form:
    "where/basename\[_locale\].multilang".

    @raise Multilang_file_not_found if the file doesn't exists.
*)

val key_exists : t -> string -> bool
(** [key_exists multilang key] checks if [key] exists in the [multilang]
    context. *)

val keys : t -> string list
(** [keys multilang] returns all known keys in [multilang] context *)

val get_value : t -> string -> string
(** [get_value multilang key] try to find the value associated to [key] in
    [multilang] context. If the key doesn't exists, it raises [Key_failure]. *)



(** {2 Pretty printing} *)

val pp_locale : Format.formatter -> locale -> unit
(** [pp_locale fmt locale] pretty print [locale] to [fmt]. *)

val pp_multilang : Format.formatter -> t -> unit
(** [pp_multilang fmt multilang] pretty print [multilang] to [fmt]. *)


(*
Local Variables:
compile-command: "make -C .."
End:
*)
