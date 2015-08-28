(*****************************************************************************)
(* The MIT License (MIT)                                                     *)
(*                                                                           *)
(* Copyright (c) 2015 OCamllang                                               *)
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


(** Module to make the lexing of an .ocamllang file *)

(** {2 Lexing} *)

val lex_until_none
  : Lexing.lexbuf -> ('a -> (string * string) -> 'a) -> 'a -> 'a
(** [lex_until_none lexbuf f a] apply [token_lang lexbuf] until it returns None,
    and apply [f acc (identifier, text)] when it returns something.

    The example below keep only the identifier:
    {[lex_until_none (Lexing.from_channel in_channel)
        (fun acc (id, _) -> id :: acc) []]}
*)


(*
Local Variables:
compile-command: "make -C .."
End:
*)
