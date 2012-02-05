"imap <buffer> <expr><CR>  neocomplcache#close_popup()."\<CR>\<Plug>DiscretionaryEnd"
imap <buffer> <expr><CR>  pumvisible() ? neocomplcache#close_popup()."\<Plug>DiscretionaryEnd" : "\<CR>"
