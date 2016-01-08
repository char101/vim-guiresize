if exists('g:loaded_guiresize')
	finish
endif
let g:loaded_guiresize = 1

" will be overwritten later
let g:guiresize_lines_max = 1000
let g:guiresize_columns_max = 1000

func s:CountSplits(dir)
	" only 1 window
	if winnr('$') == 1
		return 0
	end

	let currwin = winnr()

	" go to last window
	exe 'noautocmd '.winnr('$') . ' wincmd w'

	let cmd = a:dir == 'v' ? 'k' : 'h'
	let n = 0
	let prevwin = winnr()
	" py3 logging.info('dir = {}, cmd = {}, currwin = {}'.format(vim.eval('a:dir'), vim.eval('cmd'), vim.eval('currwin')))
	while 1
		exe 'noautocmd wincmd '.cmd
		" py3 logging.info('loop winnr = {}, prevwin= {}'.format(vim.eval('winnr()'), vim.eval('prevwin')))
		if winnr() == prevwin
			break
		endif
		let prevwin = winnr()
		let n += 1
	endwhile

	" py3 logging.info('n = {}'.format(vim.eval('n')))

	exe 'noautocmd '.currwin.' wincmd w'
	return n
endf

func s:GUIEnter()
	let g:guiresize_columns_initial = &columns
	let g:guiresize_lines_initial = &lines
endf

func s:VimResized()
	if s:CountSplits('h') == 0
		let g:guiresize_columns_initial = &columns
	endif
	if s:CountSplits('v') == 0
		let g:guiresize_lines_initial = &lines
	endif
endf

func s:ResizeGui()
	let horzsplits = s:CountSplits('h')
	let vertsplits = s:CountSplits('v')

	let columns = min([g:guiresize_columns_max, g:guiresize_columns_initial + float2nr(round(g:guiresize_columns_initial * horzsplits / 2))])
	let lines = min([g:guiresize_lines_max, g:guiresize_lines_initial + float2nr(round(g:guiresize_lines_initial * vertsplits / 2))])

	py3 logging.info('horzsplits = {}, vertsplits = {}, columns = {}, lines = {}'.format(vim.eval('horzsplits'), vim.eval('vertsplits'), vim.eval('columns'), vim.eval('lines')))

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

autocmd GUIEnter * call s:GUIEnter()
autocmd VimResized  * call s:VimResized()
autocmd WinEnter * call s:ResizeGui()
