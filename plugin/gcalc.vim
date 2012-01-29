"
" http://d.hatena.ne.jp/tasuten/20101213/1292171136
"
scriptencoding utf-8
function! GCalc(...)
  let word = a:1 

  let res = http#get('http://www.google.co.jp/complete/search?output=toolbar&q='.http#escape(word)).content

  if match(res, 'calculator_suggestion') == -1
    echohl ErrorMsg | echo '答えが出せませんでした' |  echohl None
    return
  endif

  let dom = xml#parse(res)
  echo dom.find('calculator_suggestion').attr['data']
endfunction

function! GCalcComp(ArgLead, CmdLine, CursorPos)
  return "
        \binary\n
        \octal\n
        \decimal\n
        \hexdecimal\n
        \" 
endfunction

command! -nargs=+ -complete=custom,GCalcComp GCalc call GCalc(<q-args>)

