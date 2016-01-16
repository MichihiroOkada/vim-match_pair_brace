" Version: 1.0
" Author:  Michihiro Okada <olux.888@gmail.com>
" License: VIM LICENSE

let s:save_cpo = &cpo
set cpo&vim

if !exists('g:MatchPairBrace#enable')
    let g:MatchPairBrace#enable = 1
endif

let s:blockPair = [ { "src": "do",  "dst": "end", "direction": 1  },
                  \ { "src": "end", "dst": "do",  "direction": -1 },
                  \ { "src": "{",   "dst": "}",   "direction": 1  },
                  \ { "src": "}",   "dst": "{",   "direction": -1 } ]

function! s:search_target(baseline, direction, source, target)
    let s:start = a:baseline
    let s:index = s:start
    let s:result = { "line": -1, "col": -1 }

    let s:blockCount = 1
    while s:index >= 0 && (s:index - s:start) < 500
        let s:searchStr = getline(s:index)
        if stridx(s:searchStr, a:source) != -1
            "echo "source!"
            "echo s:searchStr
            let s:blockCount += 1
        else
            if stridx(s:searchStr, a:target) != -1
                "echo "target!"
                "echo s:searchStr
                let s:blockCount -= 1
            end
        end
        "echo s:blockCount

        if s:blockCount == 0
            let s:result["line"] = s:index
            let s:result["col"]  = stridx(s:searchStr, a:target) + 1
            break
        end

        let s:index = s:index + a:direction
    endwhile
    
    return s:result
endfunction

function! s:change()
    let s:currentLine = line(".")
    let s:currentStr = getline(s:currentLine)
    "echo s:currentLine
    "echo s:currentStr
    let s:dest = { "line": -1, "col": -1 }

    for pair in s:blockPair
        "echo pair
        if stridx(s:currentStr, pair["src"]) != -1
            let s:dest = s:search_target(s:currentLine + pair["direction"], pair["direction"], pair["src"], pair["dst"])

            break
        end
    endfor

    if s:dest["line"] != -1 && s:dest["col"] != -1
        call cursor(s:dest["line"], s:dest["col"])
    end
endfunction

function! MatchPairBrace#focus_change()
    if g:MatchPairBrace#enable
        call s:change()
    endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

