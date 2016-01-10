if exists('g:loaded_guiresize')
	finish
endif
let g:loaded_guiresize = 1
let g:guiresize_disabled = 0
let g:guiresize_wincount = 0

" will be overwritten later
let g:guiresize_lines_max = 1000
let g:guiresize_columns_max = 1000

" how many columns/lines to add when splitting
let g:guiresize_columns_split = 80
let g:guiresize_lines_split = 10

func s:CountSplits()
	" only 1 window
	if winnr('$') == 1
		return 0
	end

	let currwin = winnr()

	let splits = {'v': 0, 'h': 0}
	for [k, cmd] in items({'v': 'k', 'h': 'h'})
		" go to last window
		exe 'noautocmd '.winnr('$') . ' wincmd w'

		let prevwin = winnr()
		while 1
			exe 'noautocmd wincmd '.cmd
			if winnr() == prevwin
				break
			endif
			let prevwin = winnr()
			let splits[k] += 1
		endwhile
	endfor

	exe 'noautocmd '.currwin.' wincmd w'
	return splits
endf

func s:ResizeGui()
	if g:guiresize_disabled
		return
	endif

	let splits = s:CountSplits()

	let columns = min([g:guiresize_columns_max, g:guiresize_columns_initial + float2nr(round(g:guiresize_columns_split * splits['h']))])
	let lines = min([g:guiresize_lines_max, g:guiresize_lines_initial + float2nr(round(g:guiresize_lines_split * splits['v']))])

	" py3 logging.info('horzsplits = {}, vertsplits = {}, columns = {}, lines = {}'.format(vim.eval('splits["h"]'), vim.eval('splits["v"]'), vim.eval('columns'), vim.eval('lines')))

	if columns != &columns || lines != &lines
		exe 'set columns='.columns.' lines='.lines

		" update maximum setable values
		if &columns < columns
			let g:guiresize_columns_max = &columns
		endif
		if &lines < lines
			let g:guiresize_lines_max = &lines
		endif

		" make windows equal width
		wincmd =
	endif
endf

func s:GUIEnter()
	let g:guiresize_columns_initial = &columns
	let g:guiresize_lines_initial = &lines
endf

func s:VimResized()
	let splits = s:CountSplits()
	if splits['h'] == 0
		let g:guiresize_columns_initial = &columns
	endif
	if splits['v'] == 0
		let g:guiresize_lines_initial = &lines
	endif
	" resizing is disabled if vim is resized while having splits
	let g:guiresize_disabled = splits['h'] || splits['v']

	" align windows
	wincmd =
endf

func s:WinEnter()
	if winnr('$') < g:guiresize_wincount
		" window closed = layout changed = reeable guiresize if disabled
		let g:guiresize_disabled = 0
	endif
	call s:ResizeGui()
endf

func s:WinLeave()
	let g:guiresize_wincount = winnr('$')
endf


autocmd GUIEnter   * call s:GUIEnter()
autocmd VimResized * call s:VimResized()
autocmd WinEnter   * call s:WinEnter()
autocmd WinLeave   * call s:WinLeave()
