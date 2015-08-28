{

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
  

  exception Lexer_failure of string

  let current_line = ref 1
  let incr_line  () = incr current_line
  let reset_line () = current_line := 1

  let lexer_failure fmt =
    Printf.ksprintf
      (fun msg -> raise (Lexer_failure msg))
      ("%d:" ^^ fmt) !current_line


}


let newline = ('\010' | '\013' | "\013\010")
let blank   = [' ' '\009' '\012']

let digit = ['0'-'9']
let alpha = ['a'-'z' 'A'-'Z']
let alphanum = alpha | digit | '_'

let identifier = alpha alphanum*

let text = (alphanum | digit | blank)*

rule token_lang = parse
  | (identifier as id) blank* '=' blank* (text as text) newline {
    incr_line ();
    Some (id, text)
  }

  | (identifier as id) blank* '=' blank* '"' {
    Some (id, string (Buffer.create 13) lexbuf)
  }

  | newline {
    incr_line ();
    token_lang lexbuf
  }

  | blank+ {
    token_lang lexbuf
  }

  | "(*" {
    comment 1 lexbuf
  }

  | eof {
    None
  }

  | _ {
    lexer_failure "token_lang:invalid_input(%s)" (Lexing.lexeme lexbuf)
  }

and comment level = parse
  | "(*" {
    comment (succ level) lexbuf
  }

  | "*)" {
    let level = pred level in
    if level = 0 then token_lang lexbuf else comment level lexbuf
  }

  | newline {
    incr_line ();
    comment level lexbuf
  }

  | _ {
    comment level lexbuf
  }

  | eof {
    lexer_failure "comment:eof"
  }

and string buffer = parse
  | '"' newline {
    incr_line ();
    Buffer.contents buffer
  }

  | text as text {
    Buffer.add_string buffer text;
    string buffer lexbuf
  }

  | newline as n {
    incr_line ();
    Buffer.add_string buffer n;
    string buffer lexbuf
  }

  | _ {
    lexer_failure "string:invalid_input(%s)" (Lexing.lexeme lexbuf)
  }

  | eof {
    lexer_failure "string:eof"
  }


{

  let rec lex_until_none lexbuf f a =
    reset_line ();
    match token_lang lexbuf with
    | None ->
      a
    | Some s ->
      lex_until_none lexbuf f (f a s)

}

(*
Local Variables:
compile-command: "make -C .."
End:
*)
