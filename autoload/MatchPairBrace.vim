" Version: 1.0
" Author:  Michihiro Okada <olux.888@gmail.com>
" License: VIM LICENSE

let s:save_cpo = &cpo
set cpo&vim

if !exists('g:MatchPairBrace#enable')
    let g:MatchPairBrace#enable = 1
endif

" source regex
let s:if_match = ["^if", "[^a-zA-Z]if\[ ({\]"]
let s:elseif_match = ["^elsif", "[^a-zA-Z]elsif\[ ({\]"]
let s:else_match = ["^else", "[^a-zA-Z]else\[ \]"]
let s:case_match = ["^case ", "[^a-zA-Z]case\[ \]"]
let s:when_match = ["^when ", "[^a-zA-Z]when\[ \]"]
let s:def_match = ["^def", "[^a-zA-Z]def\[ \]"]
let s:src_candidate_list = [s:if_match, s:case_match, s:def_match]

" target regex
let s:end_match = ["^end$", "^end ", " end$", " end "] 
let s:else_match = ["^else$", "^else ", " else$", " else "]
let s:when_match = ["^when$", "^when ", " when$", " when "]
let s:end_target_match = [ "[^a-zA-Z]if\[ ({\]", "^if", "^do ", " do ", "^def ", " def ", "^case", " case " ]
let s:dst_candidate_list = [s:end_match]

let s:blockPair = [ { "src": s:if_match,        "dst": ["elsif ", s:else_match, s:end_match], "direction": 1, "self": 0 },
                 \  { "src": s:elseif_match,    "dst": ["elsif ", s:else_match, s:end_match], "direction": 1, "self": 0 },
                 \  { "src": s:else_match,      "dst": [s:end_match], "direction": 1, "self": 0 },
                 \  { "src": s:case_match,      "dst": [s:when_match, s:else_match], "direction": 1, "self": 0 },
                 \  { "src": s:when_match,      "dst": [s:when_match, s:else_match, s:end_match], "direction": 1, "self": 1 },
                 \  { "src": s:def_match,       "dst": [s:end_match],  "direction": 1, "self": 0 },
                 \  { "src": s:end_match,       "dst": [s:end_target_match],  "direction": -1, "self": 0 },
                 \ ]


function! s:search_target(baseline, direction, source, target_list, self)
    let s:start = a:baseline
    let s:index = s:start
    let s:result = { "line": -1, "col": -1 }

    let s:blockCount = 1
    while s:index >= 0 && (s:index - s:start) < 500
        let found = ""
        let s:searchStr = getline(s:index)
        "echo s:searchStr
        "if stridx(s:searchStr, a:source) != -1
        "
        for src_list in a:source
            for src in src_list
                if a:self == 0 && match(s:searchStr, src) != -1
                    "echo src
                    "echo s:searchStr
                    let s:blockCount += 1
                endif
            endfor
        endfor

        for target in a:target_list
            "if stridx(s:searchStr, target) != -1
            if type(target) == 3
                " list
                for target_child in target
                    if match(s:searchStr, target_child) != -1
                        "echo target_child
                        "echo s:searchStr
                        let s:blockCount -= 1
                        let found = target_child
                        break
                    end
                endfor
            else
                if match(s:searchStr, target) != -1
                    "echo target
                    "echo s:searchStr
                    let s:blockCount -= 1
                    let found = target
                    break
                end
            endif

            if found != ""
                break
            endif
            unlet target
        endfor

        if s:blockCount == 0
            let s:result["line"] = s:index
            let s:result["col"]  = match(s:searchStr, found) + 2
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
    let s:found = 0

    for pair in s:blockPair
        "echo pair
        "if stridx(s:currentStr, pair["src"]) != -1
        for src in pair["src"]
            if match(s:currentStr, src) != -1
                echo "match"
                "let s:dest = s:search_target(s:currentLine + pair["direction"], pair["direction"], src, pair["dst"], pair["self"])
                if pair["direction"] == 1
                    let s:dest = s:search_target(s:currentLine + pair["direction"], pair["direction"], s:src_candidate_list, pair["dst"], pair["self"])
                else
                    let s:dest = s:search_target(s:currentLine + pair["direction"], pair["direction"], s:dst_candidate_list, pair["dst"], pair["self"])
                endif
                let s:found = 1

                break
            end
        endfor

        if s:found == 1
            break
        endif
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

