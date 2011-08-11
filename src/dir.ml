(*
 * Copyright 2011 (c) Julien Peeters <contact@julienpeeters.net>
 *
 * This file is part of LpTool.
 *
 * LpTool is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * LpTool is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with LpTool.  If not, see <http://www.gnu.org/licenses/>
 *
 * Author:
 *   Julien Peeters <contact@julienpeeters.net>
 *)

let fst (v,_,_) = v
let snd (_,v,_) = v
let thd (_,_,v) = v

let list path =
  let entries = Sys.readdir path in
    Array.fold_left
      ( fun state file ->
          if Sys.is_directory ( Filename.concat path file ) then
            (fst state,
             file :: ( snd state ),
	     ( `Dir file ) :: ( thd state ))
	  else
            (file :: ( fst state ),
             snd state,
             ( `File file ) :: ( thd state )) )
      ([],[],[])
      entries
