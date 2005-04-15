" An IRC client plugin for Vim
" Maintainer: Madoka Machitani <madokam@zag.att.ne.jp>
" Created: Tue, 24 Feb 2004
" Last Change: Sat, 16 Apr 2005 09:57:57 +0900 (JST)
" License: Distributed under the same terms as Vim itself
"
" Credits:
"   ircII		the basics of IRC
"   X-Chat		ideas for DCC implementation specifically
"   ERC			ideas for netsplit handling, auto-away feature etc.
"   KoRoN		creator of a BBS viewer for Vim, Chalice (very popular
"			among Japanese vim community)
"   Ilya Sher		an idea for mini-buffers for cmdline editing
"   morbuz		pointing out the error "E28: No such highlight group"
"			with s:Hilite* functions
"   alexander		pointing out the excessive CPU-time consumption,
"			feature of multiple server-connection on startup, etc
"
" Features:
"   * real-time message receiving with user interaction (many of the normal
"     mode commands available)
"   * multiple server/channel connectivity
"   * DCC SEND/CHAT functionalities
"   * logging
"   * command aliasing
"   * auto-join channels on logon
"   * auto-reconnect/rejoin after disconnect
"   * auto-away
"   * netsplit detection
"
"   A Drawback:
"     VimIRC achieves real-time message reception by implementing its own main
"     loop.  Therefore, while you are out of it, VimIRC has no way to get new
"     messages, unless you move the cursor periodically.
"
"     So my recommendation is, use a shortcut which creates a VimIRC-dedicated
"     instance of Vim, where you do not initiate normal editing sessions (See
"     Tip 1, located far below, for how to do this).
"
" Requirements:
"   * Vim 6.2 or later with perl interface enabled
"   * Perl 5.6 or later (5.8 or later if you want multibyte feature)
"
" Options:
"
"   Basic settings:
"     let g:vimirc_nick		="nickname"
"     let g:vimirc_user		="username"
"     let g:vimirc_realname	="full name"
"     let g:vimirc_server	="irc.foobar.com:6667"
"				  (default: irc.freenode.net)
"				  Your favorite IRC server.  Can be a
"				  comma-separated list.
"     let g:vimirc_umode	="user modes" set upon logon (e.g.: "+i")
"     let g:vimirc_pass		="password"
"				="password1@server1,password2@server2"
"				  Set this only if server requires
"				  authentication.
"
"   Misc.:
"     (Some of these options are configurable while running, with "/SET"
"     command)
"
"     let g:vimirc_partmsg	="message sent with QUIT/PART"
"
"     let g:vimirc_autojoin	="#chan1,#chan2"
"				="#chan1|#chan2@irc.foo.com,#chan3@irc.bar.com"
"
"				  List of channels to join upon logon.
"
"				  You can specify a password by appending
"				  ":pass" to the channel, if it requires one.
"
"				  Special keyword "list" is also accepted, in
"				  which case the list of channels will be
"				  displayed upon logon.
"
"     let g:vimirc_nickpass	="pass@irc.foo.com"
"				="nick:pass@irc.foo.com"
"				="nick1:pass1|nick2:pass2@irc.foo.com"
"
"				  List of passwords to identify yourself to
"				  NickServ.
"
"				  The first form can be used if you are using
"				  the same pass for different nicks, or you
"				  have only one nick registered.
"
"				  Use commas to separate settings for each
"				  server.  (Only irc.freenode.net is
"				  supported currently)
"
"     let g:vimirc_log		=NUMBER
"				  Set this to non-zero to enable logging
"				  feature.  (default: zero)
"				  Logs will be taken for each channel and
"				  server independently.
"
"				  Since server buffers are usually not
"				  interesting (is it?), they'll be logged only
"				  if NUMBER is greater than 1.
"     let g:vimirc_logdir	="where log files are saved"
"				  (default: ~/.vimirc)
"				  The specified directory will be created
"				  automatically.
"
"     let g:vimirc_listexpire	=NUMBER
"				  (default: 604800 (a week))
"				  Threshold time in seconds after which VimIRC
"				  discards cached channels lists.
"
"				  Channels list is cached always (from
"				  0.8.12), since obtaining one (command: /list)
"				  is rather a hard work for both server and
"				  client.  Pressing "R" on the list buffer
"				  refreshes it anyway regardless of the value.
"
"     let g:vimirc_browser	="web-browser"
"				  (default: see GetUserBrowser())
"				  The name of the web browser program which is
"				  to be invoked when hitting "<CR>" near a
"				  URL-like string.
"
"				  You can insert the special argument "%URL%",
"				  which will be replaced with the actual URL,
"				  so that you can add other arguments after it
"				  like this:
"				    "kterm -rv -e lynx %URL% &"
"
"     let g:vimirc_winmode	(abolished)
"
"     let g:vimirc_infowidth	=NUMBER
"				  (default: 20)
"				  Width of the info-bar (area to indicate
"				  which hidden buffers have new messages).
"
"   Auto-away feature:
"     let g:vimirc_autoaway	=NUMBER
"				  Set to non-zero to enable the feature.
"				  (default: zero)
"     let g:vimirc_autoawaytime	=NUMBER
"				  Threshold time in seconds after which you
"				  will be marked as `away'
"				  (default: 1800 (30 minutes))
"
"   DCC-related:
"     let g:vimirc_dccdir	="where files are downloaded"
"				  (default: ~/.vimirc/dcc)
"     let g:vimirc_dccport	=NUMBER
"				  Port-number to watch at when you set up
"				  a dcc server.  maybe necessary to set if you
"				  are behind firewall or something.
"
"   Runtime Options:
"     You can pass following options to the command :VimIRC, overriding the
"     vim variables above
"
"	-n nickname
"	-u username
"	-s server[:port]
"	-p password
"
"	Long option(s):
"
"	--real[name]="full name"
"
" Startup:
"   Type
"     :VimIRC [runtime options]<CR>
"
"   You will be prompted for several user information (nick etc.) if you have
"   not set options listed above.
"
" Usage:
"
"   Normal mode:  This is a pseudo normal mode.  Try your favorite Vim normal
"		  mode commands as usual.
"
"		  Hitting "i" or "I" will let you in the `command mode'
"		  described below, just as you do in Vim to go insert mode.
"
"		  ":", "/" and "?" keys will prompt you to enter ex-commands
"		  or search strings as usual.
"
"		  Hit <Ctrl-C> to get out of control and freely move around
"		  or do ex commands.  Hit <Space> to re-enter the normal
"		  (online) mode again.
"
"		  Hitting "q" will quit the current channel, chat, server, or
"		  VimIRC itself, depending on the context ("Q" does the last
"		  forcibly).  Contrarily, "r" and "R" keys would reconnect to
"		  servers, if they were disconnected.
"
"		  Special cases:
"
"		  * In a channels list window (which should open up with /list
"		    command), you can type "o" to sort the list, "O" to
"		    reverse it (I took these mappings from Mutt the e-mail
"		    client).  "R" will refresh the list.
"		    Hitting "<CR>" will prompt you whether to join the channel
"		    where the cursor is.
"
"		  * In a nicks window, you can hit "<CR>" to choose an action
"		    to take against the one whom the cursor is on.
"
"		  * "<C-N>" / "<C-P>" keys are available in all buffers, for
"		    cycling forward/backward through channel/server buffers.
"		    "<C-W><C-N>" / "<C-W><C-P>" do the same, with windows
"		    split open.
"
"		  * Hit "<C-L>" if you find some windows have got corrupt
"		    window sizes.  It will (hopefully) restore them.
"
"   Command mode: This is just a normal buffer opened (at the bottom of the
"		  screen|below the current window).  Enter IRC commands here.
"		  Hitting "<CR>", both in insert and normal mode, will send out
"		  the cursor line instantly either as a command or a message.
"
"		  Every IRC command starts with "/".  E.g.: /join #vim,#c
"
"		  Line without a leading slash will be sent as a message,
"		  normaly to the current channel.
"
"		  Type /help<CR> to see the list of available commands.  It's
"		  far from complete, though.
"
" Quit:
"   Type
"     /quit<CR>
"   in the IRC command line to disconnect with the current server.
"
"   To totally exit from VimIRC, press "Q" in normal mode, or type
"     VimIRCQuit<CR>
"   on the VIM command line.
"
" TODOs:
"   * handling of control characters (bold, underline etc.)
"   * multibyte support (done? I don't think so)
"   * flood protection
"   * IPv6
"   * SSL
"   * nicks auto-identification (done for freenode)
"   * command-line completion (with tab, arrows etc.)
"   * scripting (?)
"   * help (both /help command and local help file)
"   * menus (I personally never use menus)
"   * etc. etc.
"
"   Done:
"   - command-line history (?)
"   - handling of channel-mode changes
"   - separate listing of channels with sorting facilities
"   - auto reconnect/rejoin
"   - ctcp, including dcc stuffs (well, mostly)
"   - timer (it hasn't been in todo list though)
"     - auto-away
"   - logging
"   - netsplit detection
"   - command abbreviation (aliasing)
"   - authentication (just add one line to send PASS)
"
" Tips:
"   1.	If you see extreme slowness of vim's startup due to this plugin, put
"	"let loaded_vimirc=1" in your .vimrc to avoid loading this in your
"	everyday editing life.  Create a VimIRC-dedicated rc file (.vimircrc
"	or something) and put necessary settings into it.  Then set up an
"	alias (shortcut) which runs VimIRC, specifying the rc file you've just
"	created.  Like this:
"	  alias irc='gvim -i NONE -u ~/.vimircrc -c VimIRC'
"
"   2.	In the `info-bar' on the left, you'll see buffer numbers next to the
"	server/channel names.  With them, you can easily navigate
"	servers/channels like this:
"	  :sb1
"
"   3.	You can send multiple messages/commands at a time.  Prepare lines of
"	messages elsewhere and copy/paste them into the command buffer.  Then
"	visually select the lines and press <CR>.  (Do with caution so as not
"	to be kicked off!)
"
"   4.	How to send a message starting with a forward-slash?  Just precede it
"	with slash-space like this: "/ /message" (without quotes)
"
"   5.	When writing in a channel, you can use '%' where you have to type the
"	name of the current channel.  Examples:
"
"	  /msg %      You wouldn't normally write this way though.
"	  /msg %,nick This also works, at least theoretically.
"	  /notice %   '%'s in the message won't be expanded.
"	  /topic %    New Topic
"	  /invite nick %
"
"	You can even omit '%' in the last two examples.  Note also that '%'
"	will be expanded to the nick, if you are on a chat window.
"
"   6.	There is a special command prefix "SPLIT", which executes commands
"	after it in new windows:
"
"	  /split /join #chan
"	  /sp freenode
"
"	NOTE: The leading slash of the following command is optional.  Note
"	also that "split" can be abbreviated in the same manner as Vim's
"	":split".
"
"	The second example shows that you can prepend it to aliases, too
"	("freenode" should expand into "/server irc.freenode.net" in this
"	case).
"
"   7.	Type shorter by utilizing aliases.  Example:
"
"	  /alias sj split join
"
"	registers new alias "sj", expanding to "split join".  Now you can
"	type:
"
"	  /sj #chan1,#chan2
"
"	to open the channels in separate windows.
"
"   8.	Many IRC commands are abbreviatable by default.  E.g., "/join" can be
"	typed in any way as "/joi", "jo", or "/j".
"
"	Do "/h" to see how you can abbreviate commands.
"
"	NOTE: ALIASes take precedence over ABBREVIATIONs.  E.g., "/q" is an
"	abbreviation of "/query", but you can (re)define "/q" as "/quit", if
"	you prefer.
"
"   9.	There are several ways to open (hidden) channel/chat/server buffers:
"	(1) In normal mode (both online and offline), hit "<C-N>" and "<C-P>"
"	    to cycle through the buffers.  It will open buffers in the same
"	    order shown in the info-bar on the left.
"	    You can prepend count: "2<C-N>" goes to the second next buffer
"	    counted from the current one.
"	    You can also prepend "<C-W>", to open the buffer in a new window
"	    (e.g., "<C-W><C-N>", "<C-W>2<C-N>", "2<C-W><C-N>").
"	    NOTE: Count will be multiplied if used both before and after
"	    "<C-W>".
"	(2) Use ":buffer" command, as described in Tip 2.
"	(3) Visit the info-bar (with "<C-W>t") and select the one you want to
"	    open, then hit "<CR>".  "<C-W><CR>" will open it in a new window.
"	(4) If you try to join already joined channels, either via "/join" or
"	    through channels-list, they'll just safely be opened.

if exists('g:loaded_vimirc') || &compatible
  finish
endif
let s:version = '0.9.28'

let s:debug = (s:version =~# '-devel$')
if !s:debug
  let g:loaded_vimirc = 1
endif

let s:save_cpoptions = &cpoptions
set cpoptions&

"
" Developing functions
"

if 0

" Truncate too long buffers (upon logging)
function! s:TruncateBuf()
  " suggested option: vimirc_maxlines
endfunction

endif

"
" Start/Exit
"

function! s:GetUserInfo(args)
  " NOTE: This may be called more than once
  if !strlen(a:args)
	\ && (exists('s:nick') && exists('s:user') && exists('s:realname'))
    " Already set
    return 1
  endif

  let s:nick = s:StrMatch(a:args, '-n\s*\(\S\+\)', '\1')
  if !strlen(s:nick)
    let s:nick = s:GetVimVar('g:vimirc_nick')
    if !strlen(s:nick)
      let s:nick = s:GetEnv('$IRCNICK')
      if !strlen(s:nick)
	let s:nick = s:Input('Enter your nickname')
      endif
    endif
  endif

  let s:user = s:StrMatch(a:args, '-u\s*\(\S\+\)', '\1')
  if !strlen(s:user)
    let s:user = s:GetVimVar('g:vimirc_user')
    if !strlen(s:user)
      let s:user = s:GetEnv('$USER')
      if !strlen(s:user)
	let s:user = s:Input('Enter your username')
      endif
    endif
  endif

  let s:pass = s:StrMatch(a:args, '-p\s*\(\S\+\)', '\1')
  if !strlen(s:pass)
    let s:pass = s:GetVimVar('g:vimirc_pass')
  endif

  let s:realname = s:StrMatch(a:args,
		    \"--real\\%(name\\)\\==\\(['\"]\\)\\(.\\{-\\}\\)\\1", '\2')
  if !strlen(s:realname)
    let s:realname = s:GetVimVar('g:vimirc_realname')
    if !strlen(s:realname)
      let s:realname = s:GetEnv('$NAME')
      if !strlen(s:realname)
	let s:realname = s:GetEnv('$IRCNAME')
	if !strlen(s:realname)
	  let s:realname = s:Input('Enter your full name')
	endif
      endif
    endif
  endif

  let s:umode = s:StrMatch(a:args, '-m\s*\(\S\+\)', '\1')
  if !strlen(s:umode)
    let s:umode = s:GetVimVar('g:vimirc_umode')
    if !strlen(s:umode)
      let s:umode = s:GetEnv('$IRCUMODE')
    endif
  endif

  if !(strlen(s:nick) && strlen(s:user) && strlen(s:realname))
    unlet s:nick s:user s:pass s:realname s:umode
    return 0
  endif

  let s:server = s:StrMatch(a:args, '-s\s*\(\S\+\)', '\1')
  if !strlen(s:server)
    let s:server = s:GetVimVar('g:vimirc_server')
    if !strlen(s:server)
      let s:server = 'irc.freenode.net:6667'
    endif
  endif

  return 1
endfunction

function! s:GetUserBrowser()
  if !strlen(s:browser)
    if s:IsWin3264()
      let s:browser = 'start explorer'
    elseif has('mac')
      let s:browser = "osascript -e 'open location %URL%'"
    elseif has('unix')
      let s:browser = executable('mozilla')
	    \	      ? 'mozilla'
	    \	      : executable('netscape')
	    \		? 'netscape'
	    \		: executable('lynx')
	    \		  ? 'lynx'
	    \		  : executable('w3m') ? 'w3m' : ''
    endif

    if !strlen(s:browser)
      let s:browser = s:Input('Enter the name of your web browser')
      call s:OptValidate('browser')
    endif
  endif
  return s:browser
endfunction

function! s:GetServerOpt(option, server)
  let option = a:option
  " option1@server1,option2@server2
  if a:option =~ '@'
    let option = matchstr(a:option,
	  \		    '\m[^,]\+\%(@\V'.a:server.'\m\%([,:]\|$\)\)\@=')
    let option = substitute(option, '|', ',', 'g')
  endif
  return option
endfunction

function! s:GetServerUMODE(...)
  let umode = s:GetServerOpt(s:umode, (a:0 ? a:1 : s:server))
  if !strlen(umode)
    " NOTE: This cannot be an empty string: required as a second parameter of
    " USER command.
    let umode = '0'
  endif
  return umode
endfunction

function! s:GetServerPASS(...)
  return s:GetServerOpt(s:pass, (a:0 ? a:1 : s:server))
endfunction

function! s:InitVars()
  if exists('s:sid') " already init'ed
    return
  endif

  " Obtain the script ID
  map <SID>xx <SID>xx
  let s:sid = substitute(maparg('<SID>xx'), 'xx$', '', '')
  unmap <SID>xx

  let s:client  = 'VimIRC '.s:version
  " Set up the names of buffers we use
  call s:InitBufNames()
  " Init system variables
  call s:ResetSysVars()

  " User-defined options

  " Favorite farewell message
  call s:OptSet('vimirc_partmsg', (s:debug ? 'Testing ' : '').s:client.
				 \' (IRC client for Vim)')
  " Preferred language.  Encoding name which Perl's Encode module can accept
  call s:OptSet('vimirc_preflang')
  " On/off logging feature
  call s:OptSet('vimirc_log', 0)
  " Log directory
  call s:OptSet('vimirc_logdir', expand('$HOME').'/.vimirc')
  " Setings like aliases will go here
  call s:OptSet('vimirc_rcfile', s:logdir.'/.vimircrc')
  " Channels list will be refreshed after these amount of seconds have passed
  call s:OptSet('vimirc_listexpire', (60 * 60 * 24 * 7))
  " External Web browser
  call s:OptSet('vimirc_browser')
  " Directory where incoming dcc files should go
  call s:OptSet('vimirc_dccdir', s:logdir.'/dcc')
  " Port you want to listen to
  call s:OptSet('vimirc_dccport')

  " Window-related options
  " Width of info-bar
  call s:OptSet('vimirc_infowidth', 20)
  " Width of nicks-window
  call s:OptSet('vimirc_nickswidth', 12)
  " Height of command-line buffer
  call s:OptSet('vimirc_cmdheight', 1)

  " Timer-related
  " On/off auto-away feature
  call s:OptSet('vimirc_autoaway', 0)
  " Threshold time for you to be marked `away'.  MUST be in seconds
  call s:OptSet('vimirc_autoawaytime', (60 * 30))
endfunction

function! s:SetSysVars()
  call s:ResetSysVars()
  let s:opened = 1
  " When the timer was last triggered
  let s:lasttime = localtime()
  " When user did some action most recently
  let s:lastactive = s:lasttime
  let s:lastbeep = s:lasttime
endfunction

function! s:ResetSysVars()
  let s:opened = 0
  let s:in_loop = 0
  let s:autocmd_disabled = 0
  let s:current_changed = 0
  let s:split = 0
endfunction

function! s:SetGlobVars()
  let s:eadirection = &eadirection
  set eadirection=ver
  let s:equalalways = &equalalways
  let s:lazyredraw = &lazyredraw
  set lazyredraw
  let s:showbreak = &showbreak
  let &showbreak = '      '
  let s:statusline = &statusline
  let &statusline = '%{'.s:sid.'GetBufTitle()}%=%l/%L'
  let s:titlestring = &titlestring
  let s:winminheight = &winminheight
  set winminheight=1
  let s:winwidth = &winwidth
  set winwidth=12
endfunction

function! s:ResetGlobVars()
  let &eadirection = s:eadirection
  unlet s:eadirection
  let &equalalways = s:equalalways
  unlet s:equalalways
  let &lazyredraw = s:lazyredraw
  unlet s:lazyredraw
  let &showbreak = s:showbreak
  unlet s:showbreak
  let &statusline = s:statusline
  unlet s:statusline
  let &titlestring = s:titlestring
  unlet s:titlestring
  let &winminheight = s:winminheight
  unlet s:winminheight
  let &winwidth = s:winwidth
  unlet s:winwidth
endfunction

function! s:SetCmds()
  if exists(':VimIRC')
    delcommand VimIRC
  endif
  command! VimIRCQuit :call s:QuitVimIRC()
endfunction

function! s:ResetCmds()
  if exists(':VimIRCQuit')
    delcommand VimIRCQuit
  endif
  command! -nargs=* VimIRC :call s:StartVimIRC(<q-args>)
endfunction
if !exists(':VimIRC')
  call s:ResetCmds()
endif

function! s:SetAutocmds()
  augroup VimIRC
    autocmd!
    " NOTE: Cannot use CursorHold to auto re-enter the loop: getchar() won't
    " get a char since key inputs will never be waited after that event.
    execute 'autocmd CursorHold * call s:NotifyOffline()'
    execute 'autocmd BufHidden' s:bufname_channel.'* call s:PreCloseBuf_Channel()'
    execute 'autocmd BufHidden' s:bufname_chat.'* call s:PreCloseBuf_Chat()'
    execute 'autocmd BufHidden' s:bufname_list.'* call s:PreCloseBuf_List()'
    execute 'autocmd BufHidden' s:bufname_server.'* call s:PreCloseBuf_Server()'
    execute 'autocmd BufUnload' s:bufname.'* call s:DelChanServ()'
    execute 'autocmd BufWinEnter' s:bufname_channel.'* call s:PostOpenBuf_Channel()'
    execute 'autocmd BufWinEnter' s:bufname_chat.'* call s:PostOpenBuf_Chat()'
    execute 'autocmd BufWinEnter' s:bufname_list.'* call s:PostOpenBuf_List()'
    execute 'autocmd BufWinEnter' s:bufname_server.'* call s:PostOpenBuf_Server()'
    execute 'autocmd BufWinLeave' s:bufname.'* call s:ChangeChanServ(1)'
    execute 'autocmd WinEnter' s:bufname.'* call s:ChangeChanServ(1)'
  augroup END
endfunction

function! s:ResetAutocmds()
  autocmd! VimIRC
endfunction

function! s:StartVimIRC(...)
  if !has('perl')
    echoerr 'To use this, you have to build vim with perl interface. Exiting.'
    return
  endif
  if s:GetVimVar('s:opened')
    return
  endif

  " Initialize most of the internal variables.  User configurations will be
  " dealt with here, too.
  call s:InitVars()
  " Parse command-line arguments
  if !s:GetUserInfo(a:0 ? a:1 : '')
    return
  endif

  " Load system .vimircrc
  call s:RC_Load()

  " Adjust some Vim's global variables to match VimIRC's need
  call s:SetGlobVars()
  " Set up system variables
  call s:SetSysVars()

  " Remove ":VimIRC" so this won't be called twice, etc.
  call s:SetCmds()
  call s:SetAutocmds()

  " Set VimIRC's cursor color
  call s:SetHlCursor()
  call s:SetEncoding()

  " Initialize perl codes
  call s:PerlIRC()
  " Now it is OK to commence connections
  call s:StartServer()

  call s:MainLoop()
endfunction

function! s:QuitVimIRC()
  if !s:opened
    return
  endif

  try
    let s:autocmd_disabled = 1

    call s:Send_GQUIT('QUIT', '')

    call s:ResetCmds()
    call s:ResetAutocmds()
    call s:ResetGlobVars()
    call s:ResetPerlVars()

    call s:CloseWin_IRC()
    if s:in_loop
      throw 'IMGONNAQUIT'
    endif
  finally
    call s:PromptKey(0, ' Thanks for flying VimIRC', 'Title')
    call s:ResetSysVars()
  endtry
endfunction

function! s:QuitWhat(severe)
  if a:severe
    " Don't confirm when quitting with "Q"
    return s:QuitVimIRC()
  endif

  let canceld= 0
  " NOTE: `server' could get invalid value
  let server = s:GetVimVar('b:server')
  let channel= s:GetVimVar('b:channel')
  call s:SetCurServer(server)

  if s:IsChannel(channel)
    let canceld = !s:Confirm_YN('Really close channel '.channel)
    if !canceld
      return s:Send_PART('PART', channel)
    endif
  elseif s:IsNick(channel)
    let canceld = !s:Confirm_YN('Really quit chat with '.channel)
    if !canceld
      return s:QuitChat(channel)
    endif
  endif

  if s:IsConnected()
    if s:Confirm_YN((canceld ? 'Then,'
	  \		     : 'Really').' disconnect with server '.s:server)
      call s:Send_QUIT('QUIT', '')
    endif
  else
    if s:Confirm_YN((canceld ? 'Then,' : 'Really').' quit VimIRC')
      call s:QuitVimIRC()
    endif
  endif
endfunction

function! s:MainLoop()
  " NOTE: Be careful of the recursion, it may cause some obscure troubles
  if !(!s:in_loop && s:opened && s:IsSockOpen())
    return
  endif

  try
    call s:PreMainLoop()
    while 1
      if getchar(1)
	try
	  call s:HandleKey(getchar(0))
	catch /^\S\+:E/
	  " Catch some familiar, or low severity errors
	  call s:IgnoreException(v:exception)
	endtry
      endif
      if !s:DoTimer()
	break
      endif
    endwhile
  catch /^IMGONNA/
    " Get out of the loop
    " NOTE: You cannot see new messages posted while posting
  catch /^Vim:Interrupt$/
    if 1 && s:IsBufType_Command()
      call s:DoInsert(0)
    endif
  catch
    echoerr v:exception
  finally
    call s:PostMainLoop()
  endtry
endfunction

function! s:IgnoreException(exception)
  let errno = s:StrMatch(a:exception, ':E\(\d\+\):', '\1')
  let ignore= (errno =~ '^\%(2[01]\|35\|78\|132\|4\%(43\|86\|92\)\)$')
  if ignore
    if errno != 132 " pressed the same key for a long time; ignore it
      call s:EchoError('VimIRC: '.s:StrDivide(a:exception, 2))
    endif
  else
    echoerr v:exception
  endif
endfunction

function! s:PreMainLoop()
  let s:in_loop = 1
  let s:current_changed = 1
  call s:ToggleCursor(1)
  call s:ClearCommand(0)
  " Show line-cursor, so the user can easily recognize that she is online
  call s:HiliteLine('.')
endfunction

function! s:PostMainLoop()
  call s:HiliteClear()
  call s:ToggleCursor(0)
  let s:in_loop = 0
endfunction

"
" .vimircrc manipulation
"

function! s:RC_Load()
  if filereadable(s:rcfile)
    execute 'source' s:rcfile
  endif
endfunction

function! s:RC_Open(force)
  return (a:force || filereadable(s:rcfile)) && s:OpenBuf('1split', s:rcfile)
endfunction

function! s:RC_Close()
  if s:BufVisit(bufnr(s:rcfile))
    if &modified
      call s:ExecuteSilent('write!')
    endif
    call s:ExecuteSilent('bdelete!')
  endif
endfunction

function! s:RC_Varname(type, name)
  return 'vimirc_'.a:type.'_'.(a:name =~ '[^_[:alnum:]]'
	\			? '{"'.s:EscapeQuote(a:name).'"}' : a:name)
endfunction

function! s:RC_Section(section)
  if !search('^" '.a:section, 'w')
    call s:OpenNewLine()
    call append('.', '" '.a:section)
    $
  endif
endfunction

function! s:RC_Set(type, name, value)
  call s:RC_Unset(a:type, a:name)
  let varname = s:RC_Varname(a:type, a:name)
  call append('.', 'let '.varname.' = "'.s:EscapeQuote(a:value).'"')
  let g:{varname} = a:value
endfunction

function! s:RC_Unset(type, name)
  let varname = s:RC_Varname(a:type, a:name)
  while search('\m'.s:EscapeMagic(varname).'\s*=', 'w')
    call s:DelLine()
  endwhile
  unlet! g:{varname}
endfunction

"
" Buffer manipulation
"

function! s:InitBufNames()
  let s:bufname = '_VimIRC_'
  let list = 'info server list channel nicks command chat'
  while strlen(list)
    let type = s:StrDivide(list, 1)
    let s:bufname_{type} = s:bufname.toupper(type).'_'
    let list = s:StrDivide(list, 2)
  endwhile
endfunction

" I'm using buffer numbers to access buffers: accessing by name will soon fail
" if user changes directory or something.
" NOTE: I removed the `server' argument from the functions below, just for
" ease of typing (esp. on the perl's side).

function! s:GetBufNum(bufname)
  let bufnum = -1
  let varname = 's:bufnum_'.a:bufname
  if exists('{varname}')
    if bufloaded({varname})
      let bufnum = {varname}
    else
      unlet {varname}
    endif
  endif
  return bufnum
endfunction

function! s:GetBufNum_Info()
  return s:GetBufNum(s:GenBufName_Info())
endfunction

function! s:GetBufNum_Server(...)
  return s:GetBufNum(s:GenBufName_Server(a:0 ? a:1 : s:server))
endfunction

function! s:GetBufNum_List(...)
  return s:GetBufNum(s:GenBufName_List(a:0 ? a:1 : s:server))
endfunction

function! s:GetBufNum_Channel(channel, ...)
  return s:GetBufNum(s:GenBufName_Channel(a:channel, (a:0 ? a:1 : s:server)))
endfunction

function! s:GetBufNum_Nicks(channel, ...)
  return s:GetBufNum(s:GenBufName_Nicks(a:channel, (a:0 ? a:1 : s:server)))
endfunction

function! s:GetBufNum_Command(channel, ...)
  return s:GetBufNum(s:GenBufName_Command(a:channel, (a:0 ? a:1 : s:server)))
endfunction

function! s:GetBufNum_Chat(nick, server)
  return s:GetBufNum(s:GenBufName_Chat(a:nick, a:server))
endfunction

function! s:SetBufNum(bufname)
  let s:bufnum_{a:bufname} = bufnr('%')
  " Need to set this buffer as `current' if it is channel/server
  call s:ChangeChanServ(0)
  return s:bufnum_{a:bufname}
endfunction

function! s:DelBufNum(bufnum)
  unlet! s:bufnum_{bufname(a:bufnum)}
endfunction

function! s:GenBufName_Info()
  return s:bufname_info
endfunction

function! s:GenBufName_Server(...)
  return s:bufname_server.(a:0 ? a:1 : s:server)
endfunction

function! s:GenBufName_List(...)
  return s:bufname_list.(a:0 ? a:1 : s:server)
endfunction

function! s:GenBufName_Channel(channel, ...)
  return s:bufname_channel.s:SecureChannel(a:channel).'@'.(a:0 ? a:1 : s:server)
endfunction

function! s:GenBufName_Nicks(channel, ...)
  return s:bufname_nicks.s:SecureChannel(a:channel).'@'.(a:0 ? a:1 : s:server)
endfunction

function! s:GenBufName_Command(channel, ...)
  return s:bufname_command.s:SecureChannel(a:channel).'@'.(a:0 ? a:1 : s:server)
endfunction

function! s:GenBufName_Chat(nick, server)
  return s:bufname_chat.s:EscapeFName(a:nick).'@'.a:server
endfunction

function! s:SecureChannel(channel)
  return (match(a:channel, '*') >= 0) ? '' : s:EscapeFName(tolower(a:channel))
endfunction

function! s:IsBufType_IRC(...)
  let bufnum = a:0 ? a:1 : bufnr('%')
  return (bufnum >= 0 && (!match(bufname(bufnum), s:bufname)
	\		  && s:ExistsBufVar(bufnum, 'server')))
endfunction

function! s:IsBufType_ChanChat(...)
  let bufnum = a:0 ? a:1 : bufnr('%')
  return (bufnum >= 0 && (  s:IsBufType_Channel(bufnum)
	\		 || s:IsBufType_Chat(bufnum)))
endfunction

" Whether this is an appropriate place over which to open another
" channel/server
function! s:IsBufType_ChanServ(...)
  let bufnum = a:0 ? a:1 : bufnr('%')
  return (bufnum >= 0
	\ && (	s:IsBufType_Channel(bufnum) || s:IsBufType_Chat(bufnum)
	\    || s:IsBufType_Server(bufnum)  || s:IsBufType_List(bufnum)))
endfunction

function! s:IsBufType_Info(...)
  let bufnum = a:0 ? a:1 : bufnr('%')
  return (bufnum >= 0 && (s:IsBufType_IRC(bufnum)
	\		  && !match(bufname(bufnum), s:bufname_info)))
endfunction

function! s:IsBufType_Server(...)
  let bufnum = a:0 ? a:1 : bufnr('%')
  return (bufnum >= 0 && (s:IsBufType_IRC(bufnum)
	\		  && !match(bufname(bufnum), s:bufname_server)))
endfunction

function! s:IsBufType_List(...)
  let bufnum = a:0 ? a:1 : bufnr('%')
  return (bufnum >= 0 && (s:IsBufType_IRC(bufnum)
	\		  && !match(bufname(bufnum), s:bufname_list)))
endfunction

function! s:IsBufType_Channel(...)
  let bufnum = a:0 ? a:1 : bufnr('%')
  return (bufnum >= 0 && (s:IsBufType_IRC(bufnum)
	\		  && !match(bufname(bufnum), s:bufname_channel)))
endfunction

function! s:IsBufType_Nicks(...)
  let bufnum = a:0 ? a:1 : bufnr('%')
  return (bufnum >= 0 && (s:IsBufType_IRC(bufnum)
	\		  && !match(bufname(bufnum), s:bufname_nicks)))
endfunction

function! s:IsBufType_Command(...)
  let bufnum = a:0 ? a:1 : bufnr('%')
  return (bufnum >= 0 && (s:IsBufType_IRC(bufnum)
	\		  && !match(bufname(bufnum), s:bufname_command)))
endfunction

function! s:IsBufType_Chat(...)
  let bufnum = a:0 ? a:1 : bufnr('%')
  return (bufnum >= 0 && (s:IsBufType_IRC(bufnum)
	\		  && !match(bufname(bufnum), s:bufname_chat)))
endfunction

function! s:IsBufType_ServerDead()
  return (s:IsBufType_IRC() && !(s:IsBufType_Chat() && b:channel[0] == '=')
	\ && getbufvar(s:GetBufNum_Server(b:server), 'dead') + 0)
endfunction

function! s:IsServer(server)
  " TODO: Be more precise (see RFC3986)
  return (a:server =~ '[.:]')
endfunction

function! s:IsServerIRC(server)
  return (a:server =~?
      \'^\%(irc://\|\%(\w[-.[:alnum:]]\+[-.]\)\{-\}irc\)[^/]\+\%([/:]\S\+\)\=$')
endfunction

function! s:IsChannel(channel)
  return !match(a:channel, '[&#+!]')
endfunction

function! s:IsNick(channel)
  return (a:channel =~? '^=\=[-0-9\[-`a-z{-}]\+$')
endfunction

function! s:IsChanChat(channel)
  return (s:IsChannel(a:channel) || s:IsNick(a:channel))
endfunction

function! s:IsList(channel)
  return (a:channel ==# '*list')
endfunction

function! s:CanOpenChanServ()
  let autocmd_disabled = s:autocmd_disabled
  let s:autocmd_disabled = 1

  if !(s:IsBufType_ChanServ() || s:VisitBuf_ChanServ(s:GetVimVar('b:channel'),
	\					     s:GetVimVar('b:server')))
    let i = 1
    while 1
      let bufnum = winbufnr(i)
      if (bufnum < 0) || (s:IsBufType_ChanServ(bufnum) && s:BufVisit(bufnum))
	break
      endif
      let i = i + 1
    endwhile
  endif
  let s:autocmd_disabled = autocmd_disabled

  return s:IsBufType_ChanServ()
endfunction

" Change highlighting of the current buffer (later)
function! s:ChangeChanServ(auto)
  if !((a:auto && s:autocmd_disabled) || s:current_changed)
    let s:current_changed = s:IsBufType_ChanServ(a:auto
	  \					  ? expand('<abuf>') + 0
	  \					  : bufnr('%'))
  endif
endfunction

function! s:EnterChanServ(split)
  let line = getline('.')
  let rx = '^\s*[-+*]\=\[-\=\d\+\]\(\S\+\)\%(\s\+\(\S\+\)\)\=$'
  if line =~ rx
    let channel= s:StrMatch(line, rx, '\1')
    let server = s:StrMatch(line, rx, '\2')
    call s:OpenChanServ(channel, (!strlen(server) ? channel : server), a:split)
  endif
endfunction

function! s:OpenChanServ(channel, server, split)
  let s:server = a:server
  let s:split = a:split

  if s:IsChannel(a:channel)
    call s:OpenBuf_Channel(a:channel)
  elseif s:IsNick(a:channel)
    call s:OpenBuf_Chat(a:channel, a:server)
  elseif s:IsList(a:channel)
    call s:OpenBuf_List()
  else
    call s:OpenBuf_Server()
  endif

  let s:split = 0
endfunction

function! s:OpenNextChanServ(forward, split, ...)
  if s:CanOpenChanServ()
    let bufnum = s:GetBufNum_Next(a:forward, (a:0 ? a:1 : v:count1))
    if bufnum
      call s:OpenChanServ(getbufvar(bufnum, 'channel'),
	    \		  getbufvar(bufnum, 'server'),
	    \		  (a:split * (a:forward ? 1 : -1)))
    endif
  endif
endfunction

function! s:VisitBuf_ChanChat(channel, ...)
  return (strlen(a:channel)
	\ && s:VisitBuf_Cha{s:IsNick(a:channel)
	\		    ? 't' : 'nnel'}(a:channel, (a:0 ? a:1 : s:server)))
endfunction

function! s:VisitBuf_ChanServ(channel, ...)
  let server = a:0 ? a:1 : s:server
  return s:IsChanChat(a:channel)
	\ ? s:VisitBuf_ChanChat(a:channel, server)
	\ : s:VisitBuf_ServList(server)
endfunction

function! s:VisitBuf_ServList(...)
  let server = a:0 ? a:1 : s:server
  return (s:VisitBuf_Server(server) || s:VisitBuf_List(server))
endfunction

function! s:VisitBuf_Info()
  return s:BufVisit(s:GetBufNum_Info())
endfunction

function! s:VisitBuf_Server(...)
  return s:BufVisit(s:GetBufNum_Server(a:0 ? a:1 : s:server))
endfunction

function! s:VisitBuf_List(...)
  return s:BufVisit(s:GetBufNum_List(a:0 ? a:1 : s:server))
endfunction

function! s:VisitBuf_Channel(channel, ...)
  return s:BufVisit(s:GetBufNum_Channel(a:channel, (a:0 ? a:1 : s:server)))
endfunction

function! s:VisitBuf_Chat(nick, ...)
  return s:BufVisit(s:GetBufNum_Chat(a:nick, (a:0 ? a:1 : s:server)))
endfunction

function! s:VisitBuf_Nicks(channel, ...)
  return s:BufVisit(s:GetBufNum_Nicks(a:channel, (a:0 ? a:1 : s:server)))
endfunction

"
" Opening buffers
"

function! s:OpenBuf(comd, ...)
  try
    let equalalways = &equalalways
    let winminheight= &winminheight
    let winminwidth = &winminwidth

    let curbuf	= bufnr('%')
    let winline = winline()

    let &equalalways = 0
    " Avoid "not enough room" error
    set winminheight=0 winminwidth=0

    call s:ExecuteSilent(a:comd.(a:0 && strlen(a:1) ? ' '.a:1 : ''))

    setlocal noswapfile modifiable
    if !s:autocmd_disabled
      call s:RestoreWinLine(curbuf, winline)
    endif
  catch
    if s:debug
      echoerr v:exception
    endif
  finally
    let &equalalways  = equalalways
    let &winminheight = winminheight
    let &winminwidth  = winminwidth
    return !strlen(v:exception)
  endtry
endfunction

function! s:OpenBufNum(comd, bufnum)
  return (a:bufnum > 0 && s:OpenBuf(a:comd, '+'.a:bufnum.'buffer'))
endfunction

function! s:OpenBuf_Info()
  let bufnum = s:GetBufNum_Info()
  let loaded = (bufnum >= 0)
  let retval = (loaded && s:BufVisit(bufnum))

  if !retval
    let comd = 'vertical topleft '.s:infowidth.'split'
    if loaded
      call s:OpenBufNum(comd, bufnum)
    else
      let bufname = s:GenBufName_Info()
      call s:OpenBuf(comd, bufname)
      call s:InitBuf_Info(bufname)
    endif
    let retval = -1
  endif
  return retval
endfunction

function! s:OpenBuf_Server(...)
  let bufnum = s:GetBufNum_Server()
  let loaded = (bufnum >= 0)

  " No need to search the buffer when peeking: it's already done
  if s:autocmd_disabled || !(loaded && s:BufVisit(bufnum))
    " Just stay here if it is peek mode
    if !s:autocmd_disabled
      " Reuse channels list window, if found
      if !s:BufVisit(s:GetBufNum_List())
	call s:CanOpenChanServ()
      endif
      if s:split
	call s:SplitBuf_Channel()
      endif
    endif

    if loaded
      call s:OpenBuf('buffer', bufnum)
    else
      let bufname = s:GenBufName_Server()
      call s:OpenBuf('edit', bufname)
      call s:InitBuf_Server(bufname, (a:0 ? a:1 : 0))
    endif
  endif

  if loaded && !s:autocmd_disabled
    if a:0
      " a:1 is given only when user executed /server command, in which case we
      " must clear the dead state of this buffer.
      call setbufvar(bufnum, 'dead', 0)
    endif
    call s:WinBottom('$')
  endif
endfunction

function! s:OpenBuf_List()
  let bufnum = s:GetBufNum_List()
  let loaded = (bufnum >= 0)

  if s:autocmd_disabled || !(loaded && s:BufVisit(bufnum))
    " Open it next to, or on the server window
    if !s:autocmd_disabled
      if !s:BufVisit(s:GetBufNum_Server())
	call s:CanOpenChanServ()
      endif
      if s:split
	" I don't like vertical split, which was the original behaviour
	call s:SplitBuf_Channel()
      endif
    endif

    if loaded
      call s:OpenBuf('buffer', bufnum)
    else
      let bufname = s:GenBufName_List()
      call s:OpenBuf('edit', bufname)
      call s:InitBuf_List(bufname)
    endif
  endif

  if loaded && !s:autocmd_disabled
    call s:DoNormal('^')
  endif
endfunction

function! s:OpenBuf_Channel(channel)
  let bufnum = s:GetBufNum_Channel(a:channel)
  let loaded = (bufnum >= 0)

  if s:autocmd_disabled || !(loaded && s:BufVisit(bufnum))
    if !s:autocmd_disabled
      call s:CanOpenChanServ()
      if s:split
	call s:SplitBuf_Channel()
      endif
    endif

    if loaded
      call s:OpenBuf('buffer', bufnum)
      call s:RestorePrevLine()
    else
      let bufname = s:GenBufName_Channel(a:channel)
      call s:OpenBuf('edit', bufname)
      call s:InitBuf_Channel(bufname, a:channel)
    endif
    " XXX: Is this necessary?  Or necessary to all other OpenBuf_ funcs?
    if &l:winfixheight
      let &l:winfixheight = 0
    endif
  endif
endfunction

function! s:OpenBuf_Chat(nick, server)
  let bufnum = s:GetBufNum_Chat(a:nick, a:server)
  let loaded = (bufnum >= 0)

  if s:autocmd_disabled || !(loaded && s:BufVisit(bufnum))
    if !s:autocmd_disabled
      call s:CanOpenChanServ()
      if s:split
	call s:SplitBuf_Channel()
      endif
    endif

    if loaded
      call s:OpenBuf('buffer', bufnum)
      call s:RestorePrevLine()
    else
      let bufname = s:GenBufName_Chat(a:nick, a:server)
      call s:OpenBuf('edit', bufname)
      call s:InitBuf_Chat(bufname, a:nick, a:server)
    endif
  endif
endfunction

function! s:OpenBuf_Nicks(channel, ...)
  let server = a:0 ? a:1 : s:server
  let retval = s:VisitBuf_ChanChat(a:channel, server)
  if retval
    let bufnum = s:GetBufNum_Nicks(a:channel, server)
    let loaded = (bufnum >= 0)

    if !(loaded && s:BufVisit(bufnum))
      let comd = 'vertical belowright '.s:nickswidth.'split'
      if loaded
	call s:OpenBufNum(comd, bufnum)
      else
	let bufname = s:GenBufName_Nicks(a:channel, server)
	call s:OpenBuf(comd, bufname)
	call s:InitBuf_Nicks(bufname, a:channel, server)
      endif
    endif
  endif
  return retval
endfunction

function! s:OpenBuf_Command(posting)
  if !(s:opened && s:IsBufType_IRC())
    return
  endif

  " Set the current server name here, so the buffer number/name will be
  " generated properly
  if a:posting
    call s:SetCurServer(b:server)
  endif

  let channel = s:GetVimVar('b:channel')
  let bufnum  = s:GetBufNum_Command(channel)
  let loaded  = (bufnum >= 0)

  if !s:IsBufCurrent(bufnum)
    call s:VisitBuf_ChanServ(channel)
  endif

  " This is necessary for opening it in a desired height
  let &equalalways = 0

  if !(loaded && s:BufVisit(bufnum))
    let comd = 'belowright '.s:cmdheight.'split'
    if loaded
      call s:OpenBufNum(comd, bufnum)
    else
      let bufname = s:GenBufName_Command(channel)
      call s:OpenBuf(comd, bufname)
      call s:InitBuf_Command(bufname, channel)
    endif
  endif

  if !&l:winfixheight
    setlocal winfixheight
  endif

  if a:posting
    call s:OpenNewLine()
    call s:DoInsert(0)
  endif
endfunction

function! s:PostOpenBuf_Server()
  if s:autocmd_disabled
    return
  endif

  let abuf = expand('<abuf>') + 0
  let server = getbufvar(abuf, 'server')
  if strlen(server)
    call s:ResetCurChanServ('', server)
  endif
endfunction

function! s:PostOpenBuf_List()
  if s:autocmd_disabled
    return
  endif

  let abuf = expand('<abuf>') + 0
  let channel = getbufvar(abuf, 'channel')
  let server  = getbufvar(abuf, 'server')
  if strlen(server)
    call s:ResetCurChanServ(channel, server)
  endif
endfunction

function! s:PostOpenBuf_Channel()
  if s:autocmd_disabled
    return
  endif

  let abuf = expand('<abuf>') + 0
  let channel = getbufvar(abuf, 'channel')
  let server  = getbufvar(abuf, 'server')
  if strlen(channel) && strlen(server)
    let donick = (s:OpenBuf_Nicks(channel, server) && s:IsBufEmpty())
    call s:BufVisit(abuf)
    call s:ResetCurChanServ(channel, server, donick)
  endif
endfunction

function! s:PostOpenBuf_Chat()
  if s:autocmd_disabled
    return
  endif

  let abuf  = expand('<abuf>') + 0
  let nick  = getbufvar(abuf, 'channel')
  let server= getbufvar(abuf, 'server')
  if strlen(nick) && strlen(server)
    call s:OpenBuf_Nicks(nick, server)
    call s:OpenBuf_Command(0)
    call s:BufVisit(abuf)
    call s:ResetCurChanServ(nick, server)
  endif
endfunction

function! s:SplitBuf_Channel()
  let autocmd_disabled = s:autocmd_disabled
  let s:autocmd_disabled = 1

  let below = (s:split > 0)
  let hasnick = s:IsBufType_ChanChat()

  if hasnick
    call s:CloseBuf_Nicks(b:channel, b:server)
    call s:CloseBuf_Command(b:channel, b:server)
  endif
  if !&equalalways
    let &equalalways = 1
  endif

  if s:OpenBuf((below ? 'belowright' : 'aboveleft').' split')
    call s:DoWincmd(below ? 'k' : 'j')
    if !s:IsBufType_List()
      call s:WinScroll2('.')
    endif
    if hasnick
      call s:OpenBuf_Nicks(b:channel, b:server)
    endif
    call s:DoWincmd(below ? 'j' : 'k')
    " New channel will be opened here
  endif
  let s:autocmd_disabled = autocmd_disabled
endfunction

function! s:ModifyBuf(modify, ...)
  " XXX: This should NOT be called recursively
  let bufnum = a:0 ? a:1 : bufnr('%')
  if a:modify
    if !exists('s:save_undolevels')
      let s:save_undolevels = &undolevels
      set undolevels=-1
    endif
    call setbufvar(bufnum, '&modifiable', 1)
  else
    if exists('s:save_undolevels')
      let &undolevels = s:save_undolevels
      unlet s:save_undolevels
    endif
    if 0 && !s:IsBufType_Command(bufnum)
      call setbufvar(bufnum, '&modifiable', 0)
    endif
  endif
endfunction

function! s:PeekBuf(orgwin)
  if !a:orgwin
    call s:PrePeekBuf()
  else
    call s:PostPeekBuf(a:orgwin)
  endif
endfunction

function! s:PrePeekBuf()
  let s:autocmd_disabled = 1
  let &equalalways = 0
  call s:CanOpenChanServ()  " XXX: is this necessary?
  call s:OpenBuf('vertical 1split')
endfunction

function! s:PostPeekBuf(orgwin)
  call s:ExecuteSilent('close!')
  call s:WinVisit(a:orgwin)
  let s:autocmd_disabled = 0
endfunction

"
" Buffer initilization
"

function! s:RegistMap(key, func, ...)
  let keylist = a:key
  while strlen(keylist)
    let key = s:StrDivide(keylist, 1)
    let modelist = a:0 ? a:1 : 'n'
    while strlen(modelist)
      let mode = s:StrDivide(modelist, 1)
      execute mode.'noremap <buffer> <silent>' (key)
	    \ (mode == 'i' ? '<Esc>' : '').':'.
	    \ (mode != 'v' ? '<C-U>' : '').'call <SID>'.a:func.'<CR>'
      let modelist = s:StrDivide(modelist, 2)
    endwhile
    let keylist = s:StrDivide(keylist, 2)
  endwhile
endfunction

function! s:UnregistMap(key)
  let keylist = a:key
  while strlen(keylist)
    call s:ExecuteSilent('unmap <buffer> '.s:StrDivide(keylist, 1))
    let keylist = s:StrDivide(keylist, 2)
  endwhile
endfunction

function! s:DoSettings()
  setlocal bufhidden=hide
  setlocal buftype=nofile
  setlocal nolist
  setlocal nonumber
  setlocal noswapfile
  setlocal wrap

  call s:RegistMap('<Space>', 'MainLoop()')
  call s:RegistMap('<CR>', 'HandleEnter(0)')
  call s:RegistMap('<C-CR>,<S-CR>,<C-W><CR>,<C-W><C-CR>', 'HandleEnter(1)')
  call s:RegistMap('a,A,i,I,o,O', 'OpenBuf_Command(1)')
  call s:RegistMap('p,P', 'Beep(1)', 'n,v')
  call s:RegistMap('q,ZZ', 'QuitWhat(0)')
  call s:RegistMap('Q,ZQ', 'QuitWhat(1)')
  call s:RegistMap('r', 'ReconnServer(0)')
  call s:RegistMap('R', 'ReconnServer(1)')
  call s:RegistMap('<C-L>', 'RestoreWinSize(1)')
  call s:RegistMap('<C-N>', 'OpenNextChanServ(1, 0)')
  call s:RegistMap('<C-P>', 'OpenNextChanServ(0, 0)')
  call s:RegistMap('<C-W><C-N>', 'OpenNextChanServ(1, 1)')
  call s:RegistMap('<C-W><C-P>', 'OpenNextChanServ(0, 1)')
  call s:RegistMap('<F1>', 'Cmd_HELP()')

  call s:HiliteClear()
endfunction

function! s:DoSyntax()
  " NOTE: I'm really bad at syntax highlighting.  It's horrible
  " NOTE: Do not overdo.  It'll slow things down
  syntax match VimIRCUserHead display "^\S\+\%( \S\+:\)\=" contains=@VimIRCUserName
  syntax match VimIRCTime display "^\d\d:\d\d" containedin=VimIRCUserHead contained
  syntax match VimIRCBullet display "[*!]" containedin=VimIRCUserHead contained
  " User names
  syntax cluster VimIRCUserName contains=VimIRCUserPrivMSG,VimIRCUserNotice,VimIRCUserAction,VimIRCUserQuery
  syntax match VimIRCUserPrivMSG  display "<\S\+>" contained
  syntax match VimIRCUserNotice	  display "\[\S\+\]" contained
  syntax match VimIRCUserAction	  display "\*\S\+\*" contained
  syntax match VimIRCUserQuery	  display "?\S\+?" containedin=VimIRCUserHead contained

  syntax match VimIRCUnderline	  display ".\{-\}" contains=VimIRCIgnore
  syntax match VimIRCBold	  display ".\{-\}" contains=VimIRCIgnore
  syntax match VimIRCIgnore	  display "[]" contained

  highlight link VimIRCTime	    String
  highlight link VimIRCUserHead	    PreProc
  highlight link VimIRCBullet	    WarningMsg
  highlight link VimIRCUserPrivMSG  Identifier
  highlight link VimIRCUserNotice   Statement
  highlight link VimIRCUserAction   WarningMsg
  highlight link VimIRCUserQuery    Question
  highlight link VimIRCUnderline    Underlined
  " FIXME: This doesn't work
  highlight link VimIRCIgnore	    Ignore
  highlight VimIRCBold	gui=bold cterm=bold term=bold
endfunction

function! s:DoSyntax_Info()
  syntax match VimIRCInfoHasNew "^\s*+.*$" contains=VimIRCInfoIndic,VimIRCInfoBufNum
  syntax match VimIRCInfoActive "^\s*\*.*$" contains=VimIRCInfoIndic,VimIRCInfoBufNum
  syntax match VimIRCInfoDead "^\s*-.*$" contains=VimIRCInfoIndic,VimIRCInfoBufNum
  syntax match VimIRCInfoIndic "^\s*[*+-]" contained
  syntax match VimIRCInfoBufNum "\[-\=\d\+\]"

  highlight link VimIRCInfoHasNew DiffChange
  highlight link VimIRCInfoDead   Comment
  highlight link VimIRCInfoIndic  Ignore
  highlight link VimIRCInfoBufNum Comment
  execute 'highlight link VimIRCInfoActive '.s:hl_cursor
endfunction

function! s:DoSyntax_Server()
  call s:DoSyntax_Channel()
  syntax match VimIRCWallop display "!\S\+!" contained containedin=VimIRCUserHead

  highlight link VimIRCWallop	WarningMsg
endfunction

function! s:DoSyntax_List()
  syntax match VimIRCListChan "^[&#+!]\S\+\s\+\d\+" contains=VimIRCListMember
  syntax match VimIRCListMember "\<\d\+\>" contained

  highlight link VimIRCListChan	    Identifier
  highlight link VimIRCListMember   Number
endfunction

function! s:DoSyntax_Channel()
  call s:DoSyntax()
  " FIXME: Highlight for chanops disappears sometimes after buffer reopen, why?
  syntax match VimIRCChanEnter display "->" contained containedin=VimIRCUserHead
  syntax match VimIRCChanExit display "<[-=]" contained containedin=VimIRCUserHead
  syntax match VimIRCChanPriv display "[@+]" contained containedin=@VimIRCUserName

  highlight link VimIRCChanEnter  DiffChange
  highlight link VimIRCChanExit	  DiffDelete
  highlight link VimIRCChanPriv	  Statement
endfunction

function! s:DoSyntax_Nicks()
  syntax match VimIRCNicksChop "^@"
  syntax match VimIRCNicksVoice "^+"

  highlight link VimIRCNicksChop  Identifier
  highlight link VimIRCNicksVoice Statement
endfunction

function! s:DoSyntax_Chat()
  call s:DoSyntax()
  syntax match VimIRCUserChat display "=\S\+=" containedin=VimIRCUserHead contained
  highlight link VimIRCUserChat Special
endfunction

function! s:InitBuf_Info(bufname)
  let b:server	= 'Connections'
  let b:title	= ' '.b:server

  call s:DoSettings()
  call s:DoSyntax_Info()
  setlocal nowrap

  call s:SetBufNum(a:bufname)
endfunction

function! s:InitBuf_Server(bufname, port)
  let b:server	= s:server
  let b:port	= a:port

  call setline(1, s:GetTime(1).' *: Connecting with '.s:server.'...')
  call s:DoSettings()
  call s:DoSyntax_Server()

  call s:SetBufNum(a:bufname)
  call s:SetUserMode('')
endfunction

function! s:InitBuf_List(bufname)
  let b:server	= s:server
  let b:channel = '*list'
  let b:title	= '  List of channels @ '.s:server
  let b:updated = 0
  let b:updating= 1

  call s:DoSettings()
  call s:DoSyntax_List()
  setlocal nowrap
  " I take Mutt's key-bindings for sorting
  call s:RegistMap('o', 'SortSelect()')
  call s:RegistMap('O', 'SortReverse()')
  call s:RegistMap('R', 'UpdateList()')

  call s:SetBufNum(a:bufname)
endfunction

function! s:InitBuf_Channel(bufname, channel)
  let b:server	= s:server
  let b:channel = a:channel
  let b:cmode	= ''
  let b:topic	= ''
  let b:title	= '  '.a:channel.' @ '.s:server

  call setline(1, s:GetTime(1).' *: Now talking in '.a:channel)
  call s:DoSettings()
  call s:DoSyntax_Channel()

  call s:SetBufNum(a:bufname)
endfunction

function! s:InitBuf_Chat(bufname, nick, server)
  " NOTE: a:server is the name of the IRC server, not the dcc peer's
  let b:server	= a:server
  let b:channel = a:nick
  let b:title	= '  Chatting with '.a:nick

  call setline(1, s:GetTime(1).' *: Now chatting with '.a:nick)
  call s:DoSettings()
  call s:DoSyntax_Chat()

  let bufnum = s:SetBufNum(a:bufname)
  if !s:autocmd_disabled && s:OpenBuf_Nicks(a:nick, a:server)
    call s:BufVisit(bufnum)
  endif
endfunction

function! s:InitBuf_Nicks(bufname, channel, server)
  let b:server	= a:server
  let b:channel = a:channel
  let b:title	= a:channel

  call s:DoSettings()
  call s:DoSyntax_Nicks()
  setlocal nowrap
  call s:RegistMap('<CR>', 'SelectNickAction()', 'n,v')

  call s:SetBufNum(a:bufname)
  if s:IsNick(a:channel)
    call s:FillBuf_Nicks(a:channel, a:server)
  endif
endfunction

function! s:InitBuf_Command(bufname, channel)
  let b:server	= s:server
  let b:channel = a:channel
  let b:title	= '  '.(s:IsNick(a:channel)
	\		? 'Chatting with'
	\		: 'Posting to').' '.(s:IsChanChat(a:channel)
	\				      ? a:channel.' @ ' : '').s:server

  call s:DoSettings()
  setlocal expandtab
  call s:RegistMap('<CR>', 'SendLines()', 'n,i,v')
  call s:UnregistMap('a,A,i,I,o,O,p,P')

  call s:SetBufNum(a:bufname)
endfunction

function! s:FillBuf_Nicks(nick, server)
  call s:ModifyBuf(1)
  call s:BufClear()
  call setline(1, a:nick)
  call append(1, s:GetCurNick(a:server))
  call s:ModifyBuf(0)
endfunction

"
" Closing buffers
"

function! s:PreCloseBuf_Server()
  if s:autocmd_disabled
    return
  endif

  let abuf = expand('<abuf>') + 0
  let server = getbufvar(abuf, 'server')
  if strlen(server) " validity check
    call s:CloseBuf_Command('', server)
  endif
endfunction

function! s:PreCloseBuf_List()
  if s:autocmd_disabled
    return
  endif

  let abuf = expand('<abuf>') + 0
  let server = getbufvar(abuf, 'server')
  if strlen(server) && !s:VisitBuf_Server(server)
    call s:CloseBuf_Command('', server)
  endif
endfunction

function! s:PreCloseBuf_Channel()
  if s:autocmd_disabled
    return
  endif

  let abuf = expand('<abuf>') + 0
  let channel = getbufvar(abuf, 'channel')
  let server  = getbufvar(abuf, 'server')
  if strlen(channel) && strlen(server)
    call s:CloseBuf_Nicks(channel, server)
    call s:CloseBuf_Command(channel, server)
  endif
endfunction

function! s:PreCloseBuf_Chat()
  if s:autocmd_disabled
    return
  endif

  let abuf  = expand('<abuf>') + 0
  let nick  = getbufvar(abuf, 'channel')
  let server= getbufvar(abuf, 'server')
  if strlen(nick) && strlen(server)
    call s:CloseBuf_Nicks(nick, server)
    call s:CloseBuf_Command(nick, server)
  endif
endfunction

function! s:PreCloseBuf_Command(destbuf, purge)
  " Do NOT define any autocmd events to trigger this
  if s:autocmd_disabled
    return
  endif

  let cmdbuf = a:destbuf ? s:GetBufNum_Command(s:channel)
	\		 : expand('<abuf>') + 0
  let opened = s:BufVisit(cmdbuf)

  if opened || s:OpenBufNum('belowright 1split', cmdbuf)
    call s:NeatenBuf_Command(a:purge)
    if a:destbuf
      if opened && s:IsNick(s:channel)  " keep it open when chatting
	call s:RedrawScreen(0)
      else
	let s:autocmd_disabled = 1
	call s:BufClose(cmdbuf)
	let s:autocmd_disabled = 0
      endif
      call s:PostCloseBuf_Command(cmdbuf, a:destbuf)
    endif
  endif
endfunction

function! s:CloseBuf_Server()
  " Close associated windows before closing the server window
  call s:CloseBuf_List()

  let bufnum = s:GetBufNum_Server()
  if bufnum >= 0
    if s:log >= 2
      call s:LogBuffer(bufnum)
    endif
    " Mark this buffer as dead so that the next /SERVER invocation can close
    " this
    call setbufvar(bufnum, 'dead', 1)
  endif
endfunction

function! s:CloseBuf_List()
  let bufnum = s:GetBufNum_List()
  if bufnum >= 0
    call s:CacheList(bufnum)
    call s:OpenBuf_Server()
    call s:BufClose(bufnum)
  endif
endfunction

function! s:CloseBuf_Channel(channel)
  let bufnum = s:GetBufNum_Channel(a:channel)
  if bufnum >= 0
    call s:LogBuffer(bufnum)
    if !s:VisitBuf_ServList()
      call s:OpenBuf_Server()
    endif
    call s:BufClose(bufnum)
    if !s:IsBufType_List()
      call s:WinScroll2('.')
    endif
  endif
endfunction

function! s:CloseBuf_Chat(nick, server)
  let save_server = s:server
  let s:server = a:server

  let bufnum = s:GetBufNum_Chat(a:nick, a:server)
  if bufnum >= 0
    call s:LogBuffer(bufnum)
    if !s:VisitBuf_ServList()
      call s:OpenBuf_Server()
    endif
    call s:BufClose(bufnum)
    if !s:IsBufType_List()
      call s:WinScroll2('.')
    endif
  endif

  let s:server = save_server
endfunction

function! s:CloseBuf_Nicks(channel, server)
  call s:BufClose(s:GetBufNum_Nicks(a:channel, a:server))
endfunction

function! s:CloseBuf_Command(channel, server)
  call s:BufClose(s:GetBufNum_Command(a:channel, a:server))
endfunction

function! s:PostCloseBuf_Command(cmdbuf, destbuf)
  if a:destbuf != a:cmdbuf
    " Move the cursor to the destined place
    call s:BufVisit(a:destbuf)
  else
    " Move the cursor back onto the channel/server where command mode was
    " (supposedly) triggered.
    call s:VisitBuf_ChanServ(s:channel)
  endif
  if !s:IsBufType_List()
    " XXX: I do this to prevent channels from unexpectedly scrolling UP due
    " to BufClose above.
    call s:WinScroll2('.')
  endif
endfunction

" Make the command buffer look like a command-line history
function! s:NeatenBuf_Command(purge)
  call s:ModifyBuf(1)
  call s:HiliteClear()

  if a:purge
    " We move the input line to the bottom
    let line = getline('.')
    if strlen(line)
      call s:DelLine()
      " Remove duplicates, if any
      while s:SearchLine(line)
	call s:DelLine()
      endwhile
      call {strlen(getline('$')) ? 'append' : 'setline'}('$', line)
    endif
  endif

  call s:BufTrim()
  call s:OpenNewLine()
  call s:ModifyBuf(0)
endfunction

"
" Closing windows
"

function! s:CloseWin_What(cond)
  let retval = 1
  let curbuf = bufnr('%')

  let s:autocmd_disabled = 1
  call s:DoWincmd('b')
  while 1
    " TODO: Accept arguments and/or multiple conditions?
    if s:{a:cond}()
      " XXX: Vim crashes here sometimes
      if !s:WinClose()
	let retval = 0
	break
      endif
    elseif winnr() == 1
      break
    else
      call s:DoWincmd('W')
    endif
  endwhile

  call s:BufVisit(curbuf)
  let s:autocmd_disabled = 0

  return retval
endfunction

function! s:CloseWin_IRC()
  if !s:CloseWin_What('IsBufType_IRC')
    enew!
  endif
  call s:RedrawScreen(0)
endfunction

function! s:CloseWin_DeadServer()
  call s:CloseWin_What('IsBufType_ServerDead')
  call s:ClearCommand(0)
  call s:RedrawScreen(0)
endfunction

"
" Restoring windows
"

function! s:GetPrevLine()
  return line("'\"")
endfunction

" Restore the previous cursor position after re-opening a buffer
function! s:RestorePrevLine()
  let lnum = s:GetPrevLine()
  if s:autocmd_disabled
    if lnum > 0 && line('.') != lnum
      execute lnum
    endif
  else
    call s:WinScroll2(lnum)
  endif
endfunction

" Tackle the annoyance of unexpected window scrolling when opening another
" buffer
function! s:RestoreWinLine(bufnum, winline)
  let curwin = winnr()
  if s:BufVisit(a:bufnum)
    call s:WinScroll(winline() - a:winline)
    call s:WinVisit(curwin)
  endif
endfunction

function! s:RestoreWinSize(restore)
  if !s:opened
    return
  endif

  let s:autocmd_disabled = 1
  if a:restore
    let orgwin = winnr()
    let prevwin = s:GetWinNum_Prev(0)
    let equalalways = s:ToggleEqualWin(1)
  endif

  let botwin = s:DoWincmd('b')
  call s:DoWincmd('t')
  while 1
    if s:IsBufType_Nicks()
      call s:WinResize(s:nickswidth, 1)
    elseif s:IsBufType_Command()
      call s:WinResize(s:cmdheight, 0)
    elseif s:IsBufType_Info()
      call s:WinResize(s:infowidth, 1)
    endif
    if s:IsBufType_ChanServ() && !s:IsBufType_List()
      " XXX: Window could unexpectedly scroll up due to resizing
      call s:WinScroll2('.')
    else
      call s:DoNormal('^')
    endif
    if winnr() == botwin
      break
    endif
    call s:DoWincmd('w')
  endwhile

  if a:restore
    call s:WinVisit(prevwin)
    call s:WinVisit(orgwin)
    call s:RedrawScreen(1)
    let &equalalways = equalalways
  endif
  let s:autocmd_disabled = 0
endfunction

function! s:GetWinNum_Prev(restore)
  let curwin = winnr()
  call s:DoWincmd('p')
  let prevwin = winnr()
  if a:restore
    call s:DoWincmd('p')
  endif
  return prevwin - ((curwin > 1 && curwin == prevwin) ? 1 : 0)
endfunction

function! s:ToggleEqualWin(on)
  let equalalways = &equalalways
  if a:on
    let &equalalways = !&equalalways
  endif
  let &equalalways = a:on

  return equalalways
endfunction

"
" Providing some user interaction
"

function! s:HandleAt(comd)
  if a:comd =~ '[:=]$'
    let ex = (a:comd =~ ':$')
    if ex
      let comd = histget('@', -1)
    else
      call s:RedrawScreen(0)
      let comd = substitute(s:DoInput(0, '=', ''), "\\%(^[\"']\\|[\"']$\\)",
	    \							      '', 'g')
    endif
    if s:DoIterate(ex, comd, s:ComputeCount(a:comd))
      call s:PromptEnter(2)
    endif
  else
    call s:DoNormal(a:comd, 1)
  endif
endfunction

function! s:HandleEnter(shifted, ...)
  if s:IsBufType_Info()
    return s:EnterChanServ(a:shifted)
  elseif !a:shifted
    if s:IsBufType_Command()
      return s:SendLines()
    elseif s:IsBufType_Nicks()
      return s:SelectNickAction()
    endif
  endif
  return s:OpenLink(a:shifted, (a:0 ? a:1 : 1))
endfunction

function! s:HandleKey(key)
  let char = s:Key2Char(a:key)
  if !a:key
    call s:UnstickKey(0)
  endif

  call s:HiliteClear()
  " TODO: User-configurable maps
  " Place movement commands earlier, to get quick response
  if (a:key >= 2 && a:key <= 10)
	\ || char =~# '^[jkhlwbeWBE^$0*#nN+\-;,GHLM()]$'
	\ || char == "\<BS>"  || char == "\<C-Y>" || char == "\<C-U>"
	\ || char == "\<C-O>" || char == "\<C-^>"
    " One char commands
    if a:key == 9		" <TAB>
      let char = '1'.char
    endif
    call s:DoNormal(char)
  elseif char =~# '^[ p]$'	" scroll forward/backward
    call s:DoNormal(nr2char(2 * (char == ' ' ? 3 : 1)))
  elseif s:Is2KeyCmd(char)
    " Commands which take a second char
    call s:HandleMultiKey(char, 0)
  elseif (char + 0) || char == "\<C-W>"
    " Accept things like "10G", "<C-W>2k"
    call s:HandleMultiKey(char, 1)
  elseif char == "\<CR>" || char == "\<C-CR>" || char == "\<S-CR>"
    call s:HandleEnter(!(char == "\<CR>"))
  elseif char == "\<C-N>" || char == "\<C-P>"
    call s:HandleNextChanServ(char)
  elseif char == ':'
    if s:Execute(s:DoInput(0, ':', ''))
      " Pause after commands which produce outputs
      return s:PromptEnter(2)
    endif
  elseif char =~# '^[/?]$'
    call s:SearchWord(char)
  elseif char == "\<C-L>"
    call s:RestoreWinSize(1)
  elseif char =~# '^[ORo]$' && s:IsBufType_List()
    if char ==# 'R'
      call s:UpdateList()
    else
      call s:Sort{char ==# 'o' ? 'Select' : 'Reverse'}()
    endif
  elseif char =~? '^[AIO]$'
    if s:IsBufType_Command() && char =~# '^[AIa]$'
      " Position cursor at an appropriate place
      if char ==# 'I'
	call s:DoNormal('^')
      endif
      call s:DoInsert(char ==? 'a')
    else
      call s:OpenBuf_Command(1)
    endif
    call s:RedrawScreen(0)
    throw 'IMGONNAPOST'
  elseif char == "\<F1>"
    call s:Cmd_HELP()
  elseif char ==? 'r'
    call s:ReconnServer(char ==# 'R')
  elseif char ==? 'q'
    call s:QuitWhat(char ==# 'Q')
  endif

  call s:HiliteBuffer()
  " Accept repetitive inputs
  let key = s:ConsumeKey()
  if !s:IsZero(key)
    return s:HandleKey(key)
  endif

  call s:SetLastActive()
endfunction

function! s:HandleMultiKey(char, multi)
  let char = ''
  let comd = a:char
  let cnt = (a:char + 0)
  let ctrl_w = s:IsCtrl_W(a:char)
  let multi = a:multi

  while 1
    call s:ShowCmd(comd)
    let char = s:GetChar(0)
    if (char =~# '^[[:escape:]]\=$') || (multi && !cnt && s:IsZero(char))
      let comd = ''
      if s:IsZero(char)
	call s:Beep(1)
      endif
    elseif char == "\<Del>"
      let comd = (comd =~ '\d$') ? substitute(comd, '.$', '', '') : ''
      if strlen(comd)
	continue
      endif
    else
      let comd = comd.char
    endif

    " Continue if it is a number or <C-W>
    if !(multi && strlen(comd))
      break
    endif

    if (char >= '0' && char <= '9')
      " `cnt' is a mere indicator which shows that user is currently typing
      " count
      let cnt = 1
    else
      if ctrl_w
	break
      elseif s:IsCtrl_W(char)
	let cnt = 0
	let ctrl_w = 1
      elseif s:Is2KeyCmd(char)
	let multi = 0
      else
	break
      endif
    endif
  endwhile

  call s:UnstickKey(0)
  if !strlen(comd)
    return
  endif

  if char == "\<CR>" || char == "\<C-CR>" || char == "\<S-CR>"
    call s:HandleEnter((ctrl_w || char != "\<CR>"), s:ComputeCount(comd))
  elseif char =~# '^[]$' || (ctrl_w && char =~? '^[NP]$')
    " XXX: Overriding Vim's <C-W>p, which isn't very useful because of
    " redrawing of nicks and info-bar windows.
    call s:HandleNextChanServ(comd)
  elseif comd =~ '@.$'
    call s:HandleAt(comd)
  elseif comd =~# 'Z[ZQ]$'
    call s:QuitWhat(comd =~# 'Q$')
  else
    call s:DoNormal(comd, 1)
  endif
endfunction

function! s:HandleNextChanServ(comd)
  call s:OpenNextChanServ((a:comd =~? '[N]'), (a:comd =~# ''),
	\						s:ComputeCount(a:comd))
endfunction

function! s:ComputeCount(comd)
  let cnt = 1
  let nums = s:StrCompress(substitute(a:comd, '\D\+', ' ', 'g'))
  while strlen(nums)
    let cnt = cnt * s:StrDivide(nums, 1)
    let nums = s:StrDivide(nums, 2)
  endwhile
  return cnt
endfunction

" Make use of the key input for the 'Hit any key to continue' prompt
function! s:HandlePromptKey(timeout, mesg, ...)
  let key = s:PromptKey((10 * a:timeout), a:mesg, (a:0 ? a:1 : 'Question'))
  " Do nothing with space, <C-C> etc.
  if s:Key2Char(key) =~# '^[ [:return:][:escape:]]\=$'
    call s:HiliteBuffer()
  else
    try
      call s:HandleKey(key)
    catch /^\S\+:E/
      call s:IgnoreException(v:exception)
    endtry
  endif
endfunction

function! s:SendLines() range
  " TODO: Do confirmation before sending (preferably optionally)
  if !s:IsBufType_Command()
    return
  endif

  try
    let cmdbuf = bufnr('%')
    let destbuf= cmdbuf

    let i = a:firstline
    while 1
      try
	" Remember the context for a while in which the command/message was
	" entered.
	" NOTE: Current server/buffer may change each time after SendLine()
	call s:SetCurServer(getbufvar(cmdbuf, 'server'),
	      \		    getbufvar(cmdbuf, 'channel'))

	if i > a:lastline || !s:BufVisit(cmdbuf)
	  " NOTE: Do NOT put this in the `finally' clause: HandleKey() may
	  " want to reuse this command buffer
	  call s:PreCloseBuf_Command(destbuf, (a:firstline == a:lastline))
	  break
	endif
	" Get the destination buffer
	let destbuf = s:SendLine(s:ExpandAlias(s:StrTrim(getline(i))))
	" Prevent sending multiple lines too fast to the server
	call s:DoWait(a:lastline, i)
      catch /^SYNTAX ERROR/
	call s:EchoError(v:exception)
      endtry
      let i = i + 1
    endwhile
  catch /^IMGONNA/
    if s:in_loop
      throw v:exception
    endif
    return
  finally
    unlet! s:channel
  endtry

  call s:SetLastActive()
  call s:MainLoop()
endfunction

function! s:SendLine(line)
  if strlen(a:line)
    let comd = ''
    let args = a:line

    let rx = s:GetCmdRx(comd)
    if a:line =~ rx
      let s:split = strlen(s:StrMatch(a:line, rx, '\1'))

      let comd = s:ExpandCmd(s:StrMatch(a:line, rx, '\2'))
      let args = s:ExpandArgs(comd, s:StrMatch(a:line, rx, '\3'))

      if strlen(args)
	" This provision is only for removing a leading colon which user
	" unnecessarily appended to the message and adding it back!  Silly and
	" redundant
	let rx = s:GetCmdRx(comd)
	" NOTE: Matching with empty string always results in true (!!)
	if strlen(rx) && args =~ rx
	  let args = s:StrMatch(args, rx, '\1').s:StrMatch(args, rx, ' :\2')
	endif
	let args = s:StrTrim(args)
      endif
    endif

    " Values will be copied several times by value, which I'm pretending
    " I don't mind now: I just felt like making this function look simple.
    if s:PreDoSend(comd, args)
      call s:PostDoSend(comd, strlen(args))
    endif
    let s:split = 0
  endif
  return bufnr('%')
endfunction

function! s:PreSendMSG(mesg)
  let send = 0
  let mesg = substitute(a:mesg, '^/\s*', '', '')
  if strlen(mesg)
    let send = strlen(s:channel)
    if send
      call s:SendMSG('PRIVMSG', s:channel.' :'.mesg)
    else
      call s:EchoError('You are not on a channel.')
    endif
  endif
  return send
endfunction

function! s:PreDoSend(comd, args)
  let send = exists('*s:Cmd_{a:comd}')
  if send
    call s:Cmd_{a:comd}(a:args)
  else
    let send = (s:IsConnected() || a:comd =~# '^G\%(QUIT\|AWAY\)$')
    if send
      if !strlen(a:comd)
	let send = s:PreSendMSG(a:args)
      elseif exists('*s:Send_{a:comd}')
	call s:Send_{a:comd}(a:comd, a:args)
      else
	call s:DoSend(a:comd, a:args)
      endif
    else
      call s:EchoWarn('Do /SERVER first to get connected')
    endif
  endif
  return send
endfunction

" Move cursor to an appropriate window
function! s:PostDoSend(comd, arglen)
  if a:comd =~# '^\%(JOIN\|LIST\|NOTICE\|PRIVMSG\)$'
    return
  endif

  if s:IsChanChat(s:channel) && a:comd !~# '^\%(INFO\|MOTD\|NAMES\|WHO\)$'
    " If user entered the command from a channel, visit there
    call s:VisitBuf_ChanChat(s:channel)
    " Scroll to the bottom only if user is in talkative mood
    if a:comd !~# '^\%(ACTION\)\=$'
      return
    endif
  else
    " When receiving a bunch of lines, visit the server window beforehand:
    " avoid flicker caused by cursor movement between server and channel
    " windows
    if a:comd =~# '^\%(NAMES\)$' && a:arglen
      " The message will be quite short.  O.K. to exit here
      return
    endif
    call s:VisitBuf_Server()
  endif

  if s:IsBufType_ChanServ()
    " Prepare receiving lines
    call s:WinLine('$')
  endif
endfunction

function! s:SetLastActive()
  if !s:autoaway || s:lastactive >= localtime()
    return
  endif

  let lastactive = s:lastactive
  let s:lastactive = localtime()
  " Clear the `away' status only if considered to be set...
  if s:lastactive >= lastactive + s:autoawaytime
    " since I don't want to call this perl code every time you type something
    call s:Send_GAWAY('AWAY', '')
  endif
endfunction

function! s:SelectNickAction() range
  if !(s:IsBufType_Nicks() && s:IsConnected(b:server))
    return
  endif

  let nicks = ''
  let i = a:firstline
  while i <= a:lastline
    let nick = substitute(getline(i), '^[@+]\+', '', '')
    if strlen(nick)
      let nicks = nicks.(strlen(nicks) ? ' ' : '').nick
    endif
    let i = i + 1
  endwhile

  let number= a:lastline - a:firstline + 1
  let comds = "&whois\n&query\n&control\n&dcc/ctcp"
  let choice = s:Confirm('What do you do with '.nicks.'?', comds)
  if !choice
    return
  endif

  if !(choice % 2) && number > 1
    " TODO: Do it.
    return s:EchoError('Sorry, you cannot do it with mulitple persons at '.
		      \'the same time')
  endif

  if (choice == 2 || choice == 3) && !s:IsChannel(b:channel)
    return s:EchoError('You cannot do it unless you are on a channel.')
  endif

  " Set the current server appropriately, so the command will be sent to the
  " one user intended
  call s:SetCurServer(b:server, b:channel)
  try
    if choice == 1
      call s:DoSend('WHOIS', substitute(nicks, ' ', ',', 'g'))
    elseif choice == 2
      call s:StartChat(nicks)
    elseif choice == 3
      call s:SelectNickOpVoice(nicks)
    elseif choice == 4
      call s:SelectNickCTCP(nicks)
    endif
  catch /^IMGONNA/
    if s:in_loop
      throw v:exception
    endif
    return
  finally
    unlet! s:channel
  endtry

  if !s:in_loop
    call s:SetLastActive()
  endif
endfunction

function! s:SelectNickOpVoice(nicks)
  let choice = s:Confirm('Choose one of these:',
	\			      "&1 Op\n&2 Deop\n&3 Voice\n&4 Devoice")
  if choice
    let onoff = (choice % 2) ? '+' : '-'
    let mode  = choice >= 3 ? 'v' : 'o'
    call s:SetOpVoice(onoff, mode, a:nicks)
  endif
endfunction

function! s:SelectNickCTCP(nicks)
  let choice = s:Confirm('Choose one of these:',
	\		  "&send\n&chat\n&ping\n&time\n&version\nclient&info")
  if choice
    let type = 'CTCP'
    let args = ''

    if choice >= 3
      if choice == 3
	let args = 'ping'
      elseif choice == 4
	let args = 'time'
      elseif choice == 5
	let args = 'version'
      elseif choice == 6
	let args = 'clientinfo'
      endif
      let args = a:nicks.' '.args
    else
      let type = 'DCC'
      let args = (choice == 1 ? 'send' : 'chat').' '.a:nicks
    endif
    call s:Send_{type}(type, args)
  endif
endfunction

"
" Selecting sort method
"

function! s:SortSelect()
  if !s:IsBufType_List() || s:GetVimVar('b:updating')
    return
  endif

  let choice = s:Confirm("Sort by what?", "&channel\n&member\n&topic")
  if !choice
    return
  endif

  if choice == 1
    let cmp = 'channel'
  elseif choice == 2
    let cmp = 'member'
  elseif choice == 3
    let cmp = 'topic'
  endif

  let orgln = getline('.')
  call s:ModifyBuf(1)
  call s:SortList(cmp, (s:GetVimVar('b:sortdir') + 0))
  call s:ModifyBuf(0)
  call s:SearchLine(orgln)
endfunction

function! s:SortReverse()
  if !s:IsBufType_List() || s:GetVimVar('b:updating')
    return
  endif

  let orgln = line('.')
  call s:ModifyBuf(1)
  call s:BufReverse()
  call s:ModifyBuf(0)
  let b:sortdir = !(s:GetVimVar('b:sortdir'))
  execute (line('$') - orgln + 1)
endfunction

"
" Controlling VimIRC options
"

function! s:OptList(list)
  let list = a:list

  call s:EchoHL('Current setting'.(list =~ ' ' ? 's' : '').':', 'Title')
  while strlen(list)
    let opt = s:StrDivide(list, 1)
    echo opt.':' s:GetVimVar('s:'.opt)
    let list = s:StrDivide(list, 2)
  endwhile

  call s:PromptEnter(3)
endfunction

" Internalize user variables (for safety)
function! s:OptSet(opt, ...)
  let opt = substitute(a:opt, '^vimirc_', '', '')
  let s:{opt} = s:GetVimVar('g:'.a:opt)
  unlet! g:{a:opt}

  " If it wasn't defined by the user, set it
  if !strlen(s:{opt}) && a:0
    let s:{opt} = a:1
  endif
  call s:OptValidate(opt)
endfunction

function! s:OptValidate(opt)
  let var = 's:{a:opt}'
  " Fix irregularities if encountered
  if a:opt =~# '^\%(autoaway\|autoawaytime\|cmdheight\|dccport\|infowidth\|listexpire\|log\|nickswidth\)$'
    " Make sure the value is a valid numeral
    let {var} = {var} + 0
    if a:opt ==# 'dccport'
      " Avoid well-known ports
      if {var} <= 1023
	let {var} = 1024
      endif
    elseif a:opt =~# '\%(height\|width\)$'
      if {var} <= 0 " not acceptable
	let {var} = 1
      endif
      call s:RestoreWinSize(1)
    endif
  else
    let {var} = s:StrCompress({var})
    if a:opt ==# 'partmsg'
      " Prepend a leading colon
      let {var} = substitute({var}, '^[^:]', ':&', '')
    elseif a:opt ==# 'browser'
      let {var} = substitute({var}, '^!', '', '')
    elseif a:opt =~# '\%(dir\|file\)$'
      let {var} = s:ValidatePath({var})
    endif
  endif
endfunction

" "/SET option value"
function! s:Cmd_SET(optval, ...)
  let unset = (a:0 && a:1)
  " Settable options
  let numopt = 'autoaway autoawaytime browser log dccport listexpire '.
	      \'infowidth nickswidth cmdheight'
  let stropt = 'partmsg'

  let rx  = '^\(\S\+\)\%(\s\+\(.\+\)\)\=$'
  let opt = tolower(s:StrMatch(a:optval, rx, '\1'))
  let val = s:StrMatch(a:optval, rx, '\2')

  if strlen(opt)
	\ && (	opt =~# '^\%('.substitute(numopt, ' ', '\\|', 'g').'\)$'
	\    || opt =~# '^\%('.substitute(stropt, ' ', '\\|', 'g').'\)$')
    if strlen(val) || unset
      let s:{opt} = val
      call s:OptValidate(opt)
    endif
    call s:OptList(opt)
  else
    call s:OptList(numopt.' '.stropt)
  endif
endfunction

function! s:Cmd_UNSET(opt)
  call s:Cmd_SET(a:opt, 1)
endfunction

"
" Controlling user privileges
"

function! s:SetOpVoice(onoff, mode, args)
  let channel = s:StrDivide(a:args, 1)
  let nicks   = s:StrDivide(a:args, 2)
  if !s:IsChannel(channel)
    let channel = s:channel
    let nicks	= a:args
  endif

  if !(s:IsChannel(channel) && strlen(nicks))
    return s:EchoError('Syntax: /op [channel] nick(s)')
  endif

  let nicks = s:StrCompress(substitute(nicks, ',', ' ', 'g'))
  let number= strlen(substitute(nicks, '\S\+', '', 'g')) + 1
  let modes = s:StrMultiply(a:mode, number)

  call s:DoSend('MODE', channel.' '.a:onoff.modes.' '.nicks)
endfunction

function! s:Cmd_OP(args)
  call s:SetOpVoice('+', 'o', a:args)
endfunction

function! s:Cmd_DEOP(args)
  call s:SetOpVoice('-', 'o', a:args)
endfunction

function! s:Cmd_VOICE(args)
  call s:SetOpVoice('+', 'v', a:args)
endfunction

function! s:Cmd_DEVOICE(args)
  call s:SetOpVoice('-', 'v', a:args)
endfunction

"
" Aliasing
"

function! s:ExpandAlias(line)
  let line = a:line
  let rx = s:GetCmdRx('')
  if a:line =~ rx
    let varname = s:RC_Varname('alias', toupper(s:StrMatch(a:line, rx, '\2')))
    if exists('g:{varname}')
      let args = s:StrMatch(a:line, rx, '\3')
      let line = g:{varname}.(strlen(args) ? ' '.args : '')

      if strlen(s:StrMatch(a:line, rx, '\1')) && match(line, '/\csplit')
	let line = '/SPLIT '.line
      endif
    endif
  endif
  return line
endfunction

function! s:Cmd_ALIAS(line)
  let rx = '^/\=\(\S\+\)\s\+/\=\(.\+\)$'
  if a:line =~ rx
    if s:RC_Open(1)
      let alias = toupper(s:StrMatch(a:line, rx, '\1'))
      let comd	= s:StrMatch(a:line, rx, '/\2')
      call s:RC_Section('Aliases')
      call s:RC_Set('alias', alias, comd)
    else
      call s:EchoError('Failed in registering alias')
    endif
    call s:RC_Close()
  else
    call s:EchoError('Syntax: /ALIAS alias command (with arguments)')
  endif
endfunction

function! s:Cmd_UNALIAS(alias)
  if s:RC_Open(0)
    call s:RC_Unset('alias', toupper(substitute(a:alias, '^/', '', '')))
  endif
  call s:RC_Close()
endfunction

" Expand command aliases (after s:ExpandAlias())
function! s:ExpandCmd(comd)
  " NOTE: Beware of collisions
  let comd = toupper(a:comd)
  if comd =~# '^\%(B\%[YE]\|E\%[XIT]\|SI\%[GNOFF]\)$'
    let comd = 'QUIT'
  elseif comd =~# '^\%(CH\%[AT]\)$'
    let comd = 'QUERY'
  elseif comd =~# '^DA\%[TE]$'
    let comd = 'TIME'
  elseif comd =~# '^\%(LE\%[AVE]\)$'
    let comd = 'PART'
  elseif comd =~# '^\%(ME\)$'
    let comd = 'ACTION'
  elseif comd =~# '^\%(M\%[SG]\)$'
    let comd = 'PRIVMSG'
  elseif comd =~# '^\%(NICKS\)$'
    let comd = 'NAMES'
  elseif comd =~# '^\%(\%(RE\)\=CO\%[NNECT]\)$'
    let comd = 'SERVER'
  else
    " Handle abbreviations
    if comd =~# '^AC\%[TIO]$'
      let comd = 'ACTION'
    elseif comd =~# '^AL\%[IA]$'
      let comd = 'ALIAS'
    elseif comd =~# '^AWA\=$'
      let comd = 'AWAY'
    elseif comd =~# '^CTC\=$'
      let comd = 'CTCP'
    elseif comd =~# '^DC$'
      let comd = 'DCC'
    elseif comd =~# '^DEO$'
      let comd = 'DEOP'
    elseif comd =~# '^DES\%[CRIB]$'
      let comd = 'DESCRIBE'
    elseif comd =~# '^DEV\%[OIC]$'
      let comd = 'DEVOICE'
    elseif comd =~# '^GA\%[WA]$'
      let comd = 'GAWAY'
    elseif comd =~# '^GQ\%[UI]$'
      let comd = 'GQUIT'
    elseif comd =~# '^H\%[EL]$'
      let comd = 'HELP'
    elseif comd =~# '^INF\=$'
      let comd = 'INFO'
    elseif comd =~# '^J\%[OI]$'
      let comd = 'JOIN'
    elseif comd =~# '^L\%[IS]$'
      let comd = 'LIST'
    elseif comd =~# '^MOD\=$'
      let comd = 'MODE'
    elseif comd =~# '^MOT$'
      let comd = 'MOTD'
    elseif comd =~# '^NA\%[ME]$'
      let comd = 'NAMES'
    elseif comd =~# '^NIC\=$'
      let comd = 'NICK'
    elseif comd =~# '^NO\%[TIC]$'
      let comd = 'NOTICE'
    elseif comd =~# '^O$'
      let comd = 'OP'
    elseif comd =~# '^PAR\=$'
      let comd = 'PART'
    elseif comd =~# '^PIN\=$'
      let comd = 'PING'
    elseif comd =~# '^PR\%[IVMS]$'
      let comd = 'PRIVMSG'
    elseif comd =~# '^Q\%[UER]$'
      let comd = 'QUERY'
    elseif comd =~# '^QUI$'
      let comd = 'QUIT'
    elseif comd =~# '^S\%[ERVE]$'
      let comd = 'SERVER'
    "elseif comd =~# '^SET$'
    elseif comd =~# '^T\%[IM]$'
      let comd = 'TIME'
    elseif comd =~# '^TO\%[PI]$'
      let comd = 'TOPIC'
    elseif comd =~# '^UNA\%[LIA]$'
      let comd = 'UNALIAS'
    elseif comd =~# '^UNSE\=$'
      let comd = 'UNSET'
    elseif comd =~# '^V\%[OIC]$'
      let comd = 'VOICE'
    elseif comd =~# '^WH$'
      let comd = 'WHO'
    elseif comd =~# '^WHOAM\=$'
      let comd = 'WHOAMI'
    elseif comd =~# '^WHOI$'
      let comd = 'WHOIS'
    endif
  endif
  return comd
endfunction

" Expand '%' to the current channel, etc.
" TODO: How should we behave to syntax errors?
function! s:ExpandArgs(comd, args)
  "let errmsg = 'SYNTAX ERROR '
  let args = a:args

  if a:comd =~# '^\%(MODE\)$'
    if a:args =~ '^\%([-+].*\)\=$'
      let args = (s:IsChannel(s:channel) ? s:channel
	    \				 : s:GetCurNick()).' '.a:args
    endif
  elseif a:comd =~# '^\%(NAMES\)$'
    " Syntax: CHANNEL [<comma> CHANNEL]*
    " User might delimit targets with spaces, which is wrong
    let args = s:ExpandChannel(substitute(a:args, '\s\+', ',', 'g'))
  elseif a:comd =~# '^WHOIS$'
    " Syntax: [SERVER] USER [<comma> USER]*
    let server= s:ExpandChannel(s:StrDivide(a:args, 1))
    let nicks = s:ExpandChannel(substitute(s:StrDivide(a:args, 2),
	  \						    '\s\+', ',', 'g'))
    let args  = s:StrTrim(server.(s:IsNick(server) ? ',' : ' ').nicks)
  elseif a:comd =~# '^WHOWAS$'
    " Syntax: USER [COUNT [SERVER]]
    " NOTE: Some servers accept multiple users, delimited with commas, whereas
    " RFC1459 specifies only one user.  I adopt the latter.
    if 1 || a:args =~ '^\S\+\%(\s\+-\=\d\+\%(\s\+\S\+\)\=\)\=$'
      let args = s:ExpandChannel(a:args, ' ')
    endif
  elseif a:comd =~# '^\%(ISON\|USERHOST\)$'
    " Syntax: USER [<space> USER]*
    " User might delimit targets with commas, which is wrong
    let args = s:ExpandChannel(substitute(a:args, ',', ' ', 'g'), ' ')
  elseif a:comd =~# '^\%(INVITE\)$'
    " Syntax: USER CHANNEL
    let rx = '^\(\S\+\)\%(\s\+\(\S\+\)\)'.(s:IsChannel(s:channel)
	  \						      ? '\=' : '').'$'
    if a:args =~ rx
      let nick	  = s:StrMatch(a:args, rx, '\1')
      let channel = s:StrMatch(a:args, rx, '\2')
      let args = nick.' '.{s:IsChannel(channel) ? 'l' : 's'}:channel
    endif
  elseif !s:IsCmdUnary(a:comd)
    if a:comd =~# '^\%(ACTION\)$'
      " NOTE: "/ME" command MUST come with NO targets specified
      if strlen(s:channel)
	let args = s:channel.' '.a:args
      endif
    elseif (  a:comd =~# '^\%(DESCRIBE\|NOTICE\|PART\|PRIVMSG\|TOPIC\)$'
	  \|| a:comd =~# '^\%(KICK\)$')
      " Syntax: TARGET [MESSAGE]
      "		CHANNEL USER [MESSAGE]
      " Divide arguments into two parts, to see if the former is righteously
      " a channel or not
      let rx = '^\(\S\+\)\%(\s\+\(.\+\)\)\=$'
      let channel = s:ExpandChannel(s:StrMatch(a:args, rx, '\1'))
      let message = s:StrMatch(a:args, rx, '\2')

      if !s:IsChannel(channel) && a:comd =~# '^\%(KICK\|PART\|TOPIC\)$'
	" If user ommitted channel(s), supply the current one
	let channel = s:channel
	let message = a:args
      endif
      " Restore it, potentially squeezing the spaces in-between
      if strlen(channel)
	let args = channel.' '.message
      endif
    endif
  endif

  return args
endfunction

function! s:ExpandChannel(channel, ...)
  let delimit = (a:0 && strlen(a:1)) ? a:1 : ','
  let channel = substitute(a:channel, '%', s:channel, '')
  let channel = substitute(channel, '%', '', 'g')
  let channel = s:StrCompress(channel, delimit)
  return channel
endfunction

" Syntax: COMMAND [MESSAGE]
function! s:IsCmdUnary(comd)
  return (a:comd =~# '^\%(G\=\%(AWAY\|QUIT\)\|WALLOPS\)$')
endfunction

" Syntax: COMMAND TARGET [MESSAGE]
function! s:IsCmdBinary(comd)
  return (a:comd =~#
\'^\%(ACTION\|DESCRIBE\|KILL\|NOTICE\|PART\|PRIVMSG\|TOPIC\|SQU\%(ERY\|IT\)\)$')
endfunction

" Syntax: COMMAND CHANNEL USER [MESSAGE]
function! s:IsCmdTernary(comd)
  return (a:comd =~# '^\%(KICK\)$')
endfunction

function! s:GetCmdRx(comd)
  let rx = ''
  if !strlen(a:comd)
    " Pattern of the command line
    let rx = '^/\(\csp\%[lit]\s\+/\=\)\=\(\S\+\)\%(\s\+\(.\+\)\)\=$'
  elseif s:IsCmdUnary(a:comd)
    let rx = '^\(\):\=\(.\+\)$'
  elseif s:IsCmdBinary(a:comd)
    let rx = '^\(\S\+\)\s\+:\=\(.\+\)$'
  elseif s:IsCmdTernary(a:comd)
    let rx = '^\(\S\+\s\+\S\+\)\s\+:\=\(.\+\)$'
  endif
  return rx
endfunction

"
" Wrapper functions for commencing communication
"

function! s:ReconnServer(force)
  let server = s:GetVimVar('b:server')
  if !s:IsServer(server)
    let server = s:server
  endif
  if !s:IsConnected(server) && (a:force
	\			|| s:Confirm_YN('Reconnect to server '.server))
    call s:Cmd_SERVER(server)
    call s:MainLoop()
  endif
endfunction

function! s:StartServer(...)
  let manual = a:0
  let list = manual ? a:1 : s:server
  let retval = (strlen(list)
	\	&& (!manual || s:Confirm_YN('Open '.list.' with VimIRC')))

  if retval
    " irc.server.com/#channel
    let rx = '^\%(irc://\)\=\(..\{-\}\)\%([/:]\(\S\+\)\)\=$'
    " NOTE: The above style of channel specification is not allowed for
    " `g:vimirc_server'. Use `g:vimirc_autojoin' instead.

    while strlen(list)
      let server = s:StrDivide(list, 1)
      if strlen(server)
	let channel= manual ? s:StrMatch(server, rx, '\2') : ''
	let server = s:StrMatch(server, rx, '\1')

	if manual
	  call s:HiliteURL(server)
	  if strlen(channel)
	    " I encountered this notation, unfortunately (missing #):
	    "	irc://irc.efnet.net/hydrairc
	    let channel = (s:IsChannel(channel) ? '' : '#').channel
	    if s:StartChannel(channel, server) > 0  " already logged-in
	      return retval
	    endif
	  endif
	endif
	call s:Cmd_SERVER(server)
      endif
      let list = s:StrDivide(list, 2)
    endwhile
  endif
  return retval
endfunction

function! s:StartChannel(channel, ...)
  let server = a:0 ? a:1 : s:GetVimVar('b:server')
  let retval = (s:IsServer(server) && s:Confirm_YN('Join channel '.a:channel))
  if retval
    if !s:IsBufType_List()
      call s:HiliteURL(a:channel)
    endif
    if s:IsConnected(server)
      call s:SetCurServer(server)
      call s:Send_JOIN('JOIN', a:channel)
    else
      " Open specified channel after logging in the server
      " FIXME: This can be overridden if called before the previous login
      " attempt completes
      let s:autojoin = a:channel
      let retval = -1
    endif
  endif
  return retval
endfunction

" TODO: Keep track of the state of the nick you are chatting with (ison, nick
" change)
function! s:StartChat(nick, ...)
  " Open up a separate window as with DCC CHAT
  " TODO: Accept multiple nicks
  if s:IsNick(a:nick)
    call s:OpenBuf_Chat(a:nick, (a:0 ? a:1 : s:server))
    call s:OpenBuf_Command(1)
    throw 'IMGONNAPOST'
  elseif strlen(a:nick)
    call s:EchoError('Not a proper nick: '.a:nick)
  endif
endfunction

function! s:StartWeb(url)
  let comd = (s:IsServer(a:url)
	\		    && s:Confirm_YN('Open '.a:url.' with web browser'))
	\	? s:GetUserBrowser() : ''
  let retval = strlen(comd)

  if retval
    " "irc..." server not opened with VimIRC
    let url = (a:url !~ '^\a\+://' ? 'http://' : '').a:url
    call s:HiliteURL(url)

    let url = s:StrQuote(s:EscapeFName(url))
    if comd =~# '%URL%'
      " Avoid special chars to be replaced with the matched pattern
      let comd = substitute(comd, '%URL%', escape(url, '&\'), 'g')
    else
      let comd = comd.' '.url
    endif
    call s:ExecuteShell(comd)
  endif
  return retval
endfunction

function! s:Cmd_QUERY(args)
  if !strlen(a:args)
    call s:QuitChat(s:channel)
  else
    call s:StartChat(a:args)
  endif
endfunction

function! s:UpdateList()
  if s:IsBufType_List() && s:IsConnected(b:server)
    " Prevent excessive updating
    if (localtime() - b:updated) > 60
      call s:SetCurServer(b:server)
      call s:UnloadList()
      call s:Send_LIST('LIST', '')
    else
      call s:EchoWarn('You are too eager to update.  Wait another minute.')
    endif
    call s:MainLoop()
  endif
endfunction

function! s:DoAutoJoin()
  let autojoin = s:GetServerOpt(s:GetVimVar('g:vimirc_autojoin'), s:server)
  while strlen(autojoin)
    let channel = s:StrDivide(autojoin, 1)
    if channel ==? 'list'
      if s:GetBufNum_List() < 0
	call s:Send_LIST('LIST', '')
      endif
    else
      call s:Send_JOIN('JOIN', substitute(channel, ':', ' ', ''))
    endif
    let autojoin = s:StrDivide(autojoin, 2)
  endwhile

  if exists('s:autojoin')
    call s:Send_JOIN('JOIN', s:autojoin)
    unlet s:autojoin
  endif
endfunction

"
" Opening URLs with web browser
" (heavily borrowed from Chalice)
"

function! s:ExtractChannel(str)
  return matchstr(a:str, '\%(^\|\W\)\@<=[&#+!][^,:[:space:]]\+')
endfunction

function! s:ExtractURL(str)
  " FIXME: Filenames would likely be regarded as URLs
  " Catch raw IPs?
  let url = matchstr(a:str,
	\	'\%(\a\+://\)\=\%(\w[-.[:alnum:]]\+\.\)\+\a\{2,\}\%(/\S*\)\=')
  if strlen(url)
    let url = s:ValidateURL(url)
  endif
  return url
endfunction

function! s:ExtractLink()
  let link = ''
  let line = getline('.')
  if line =~ '^\S\+ \*:'
    return link
  endif

  let word = expand('<cWORD>')
  let link = s:ExtractChannel(word)
  if !strlen(link)
    " Get URL under/after/before cursor
    let link = s:ExtractURL(word)
    if !strlen(link)
      let link = s:ExtractURL(strpart(line, col('.')))
      if !strlen(link)
	let link = s:ExtractURL(line)
	if !strlen(link)
	  let link = s:ExtractChannel(line)
	endif
      endif
    endif
  endif
  return link
endfunction

function! s:OpenLink(split, ...)
  let link = s:ExtractLink()
  let open = strlen(link)

  if open
    let s:split = a:split
    let open = s:IsChannel(link) ? s:StartChannel(link)
	  \			 : (s:IsServerIRC(link) && s:StartServer(link)
	  \						|| s:StartWeb(link))
    let s:split = 0
  endif
  if !(open || s:IsBufType_List())
    " Advance cursor if user selected nothing: this is called via <CR> key
    call s:DoNormal((a:0 ? a:1 : v:count1)."\<CR>")
  endif
endfunction

"
" Logging
"

function! s:LogBuffer(bufnum)
  if s:log && s:MakeDir(s:logdir) && bufloaded(a:bufnum)
	\ && (s:BufVisit(a:bufnum) || s:OpenBufNum('split', a:bufnum))
	\ && !(s:IsBufEmpty() || (s:GetVimVar('b:lastsave') >= line('$')))
    let save_cpoptions = &cpoptions
    set cpoptions-=A

    let range = ((exists('b:lastsave') ? b:lastsave : 0) + 1).',$'
    let logfile = s:logdir.'/'.s:GenFName_Log()

    " If the file is loaded in another buffer, unload it
    call s:BufUnload(logfile)

    execute 'redir >>' logfile
    silent echo '(Logged at' s:GetTime(0).")\n"
    redir END
    call s:ExecuteShell(range.'write! >> '.logfile)

    let b:lastsave = line('$')
    let &cpoptions = save_cpoptions
  endif
endfunction

function! s:GenFName_Log()
  " I'm prepending your nick to avoid corrupted data in case you're running
  " several instances.  No locking.
  return s:EscapeFName(s:GetCurNick().'@'.b:server.(exists('b:channel')
	\					    ? '.'.b:channel
	\					    : ''))
endfunction

"
" Caching
"

function! s:GenFName_List()
  return s:logdir.'/'.b:server.'.list'
endfunction

function! s:CacheList(bufnum)
  if (getbufvar(a:bufnum, 'updated') + 0 > 0) && s:MakeDir(s:logdir)
	\ && (s:BufVisit(a:bufnum) || s:OpenBufNum('split', a:bufnum))
    call s:Write(s:GenFName_List(), 0)
    let b:updated = 0
  endif
endfunction

function! s:LoadList()
  call s:OpenBuf_List()

  if s:IsBufEmpty()
    let list = s:GenFName_List()
    if filereadable(list) && (localtime() - getftime(list)) < s:listexpire
      call s:Read(list)
    endif
  endif
  return !s:IsBufEmpty()
endfunction

function! s:UnloadList()
  let b:updated = localtime()
  let b:updating= 1
  call s:ModifyBuf(1)
  call s:BufClear()
  call s:ModifyBuf(0)
  call delete(s:GenFName_List())
endfunction

"
" Notifications
"

function! s:NotifyNewEntry(force)
  " If the bottom line is already visible, or just forced to do so,
  if a:force || s:IsBottomVisible(1)
    " Scroll down
    call s:HiliteLine('$')
  else
    " And if not, do not scroll.  User might want to stay there to read old
    " messages
    call s:Beep(1)
  endif
endfunction

function! s:NotifyOffline()
  call s:HiliteClear()

  if s:IsBufType_IRC()
    echo s:IsSockOpen() ? s:IsBufType_Command()
	  \		    ? 'Hitting <CR> will send out the current line'
	  \		    : 'Hit <Space> to get online'
	  \		: 'Do /SERVER to get connected'
  endif
  if s:in_loop
    if s:debug
      call s:EchoHL('You have to consider seriously why you are seeing this '
		   \'message', 'WarningMsg')
    endif
    let s:in_loop = 0
  endif

  try
    call s:DoTimer()
  catch /^Vim:Interrupt$/
  endtry
endfunction

function! s:GetBufTitle()
  return exists('b:title') ? b:title : bufname('%')
endfunction

function! s:SetTitleBar(time)
  let &titlestring = s:client." [".strftime('%H:%M', a:time).']: '.
		    \(s:IsBufType_IRC()
		    \ ? b:server.' '.(s:IsBufType_Channel()
		    \		      ? b:channel.': '.b:topic : '')
		    \ : fnamemodify(expand('%'), ':p'))
  " NOTE: Redrawing is necessary to update the title
  redraw
endfunction

function! s:SetUserMode(umode)
  let bufnum = s:GetBufNum_Server()
  if bufnum >= 0
    let umode = (a:umode == '+' ? '' : a:umode)
    call setbufvar(bufnum, 'umode', umode)
    call setbufvar(bufnum, 'title', '  '.s:GetCurNick().
			\(strlen(umode) ? " [".umode.']' : '').' @ '.s:server)
  endif
endfunction

function! s:SetChannelTopic(channel, topic)
  let bufnum = s:GetBufNum_Channel(a:channel)
  if bufnum >= 0
    call setbufvar(bufnum, 'topic', a:topic)
  endif
endfunction

function! s:SetChannelMode(channel, cmode)
  let bufnum = s:GetBufNum_Channel(a:channel)
  if bufnum >= 0
    call setbufvar(bufnum, 'cmode', a:cmode)
    call setbufvar(bufnum, 'title', '  '.a:channel." [".a:cmode.'] @ '.s:server)
  endif
endfunction

"
" Help
"

function! s:Cmd_HELP(...)
  if a:0 && strlen(a:1)
    if a:1 ==? 'DCC'
      call s:Cmd_DCCHELP()
    elseif a:1 =~? '^\%(SERVER\|REMOTE\)\>'
      call s:Cmd_REMOTEHELP(s:StrDivide(a:1, 2))
    endif
    return
  endif

  try
    let save_more = &more
    set more

    let hlname = 'Title'
    call s:EchoHL(' VimIRC Help', hlname)
    echo "\n"
    call s:EchoHL(' Available commands:', hlname)
    call s:EchoHL(' (letters in [] are optional)', 'Comment')
    echo "\n"

    call s:EchoHL('/s[erver] [host[:port] [password]]', hlname)
    echo "\tTry to connect with a new server.  Or reconnect the current server"
    echo "\twhen no argument is given."
    echo "\tSynonym: co[nnect]"
    call s:EchoHL('/qui[t] [reason]', hlname)
    echo "\tDisconnect with the current server."
    echo "\tSynonyms: b[ye], e[xit], si[gnoff]."
    call s:EchoHL('/gq[uit] [reason]', hlname)
    echo "\tDisconnect with all the servers."
    echo "\n"
    call s:EchoHL('/l[ist]', hlname)
    echo "\tShow the list of active channels on the server."
    echo "\n"
    call s:EchoHL('/j[oin] channel(s) [key(s)]', hlname)
    echo "\tJoin specified channels.  Use commas to separate channels."
    call s:EchoHL('/pa[rt] [channel(s)] [message]', hlname)
    echo "\tExit from the specified channels.  If channels are ommitted, exit"
    echo "\tfrom the current channel."
    echo "\tSynonym: le[ave]."
    echo "\n"
    call s:EchoHL('/to[pic] [channel] [topic]', hlname)
    echo "\tSet or show the current topic for channel."
    echo "\n"
    call s:EchoHL('/q[uery] [nick]', hlname)
    echo "\tWith nick, start a query session with the user.  Without nick,"
    echo "\tclose the current query session."
    echo "\tSynonym: ch[at]"
    echo "\n"
    call s:EchoHL('message', hlname)
    echo "\tSend a message to the current channel, or the nick currently"
    echo "\tchatting with."
    echo "\n"
    call s:EchoHL('/m[sg] target message', hlname)
    echo "\tSend a message to the nick/channel."
    call s:EchoHL('', hlname)
    echo "\n"
    call s:EchoHL('/me message', hlname)
    echo "\tSend a message to the current channel/query target, playing some"
    echo "\trole."
    call s:EchoHL('/des[cribe] target message', hlname)
    echo "\tSend a message to the nick/channel, playing some role."
    echo "\n"
    call s:EchoHL('/t[ime]', hlname)
    echo "\tShow what time it is on the server now."
    echo "\tSynonym: da[te]"
    echo "\n"
    call s:EchoHL('/aw[ay] [reason]', hlname)
    echo "\tWith reason, notify the server that you are away.  Without reason,"
    echo "\tnotify her that you are back."
    call s:EchoHL('/ga[way] [reason]', hlname)
    echo "\tDo the same thing with all servers."
    echo "\n"
    call s:EchoHL('/whoa[mi]', hlname)
    echo "\tShow the current nickname of you."
    call s:EchoHL('/whoi[s] [server] nick(s)', hlname)
    echo "\tShow information on nicks, separated by commas."
    echo "\n"
    call s:EchoHL('/o[p] [channel] nick(s)', hlname)
    call s:EchoHL('/v[oice] [channel] nick(s)', hlname)
    echo "\tGive operator or voice privileges to the selected nick(s)."
    echo "\tUse spaces or commas to separate them."
    call s:EchoHL('/deo[p] [channel] nick(s)', hlname)
    call s:EchoHL('/dev[oice] [channel] nick(s)', hlname)
    echo "\tDeprive operator or voice privileges of the selected nick(s)."
    echo "\n"
    call s:EchoHL('/set [option [value]]', hlname)
    echo "\tSet or show internal option values.  List of settable options will"
    echo "\tbe displayed if option is ommited."
    call s:EchoHL('/uns[et] option', hlname)
    echo "\tClear the value of the option"
    echo "\n"
    call s:EchoHL('/al[ias] /new-command /blah blah', hlname)
    echo "\tAdd a new command \"new-command\" which expands into \"blah blah\"."
    call s:EchoHL('/una[lias] /new-command', hlname)
    echo "\tRemove it."
    echo "\n"
    call s:EchoHL('/sp[lit]', hlname)
    echo "\tThis is a prefix to commands such as /join, /list, /query, and"
    echo "\t/server, to execute those commands in separate windows."
    echo "\n"
    call s:EchoHL('/h[elp]', hlname)
    echo "\tDisplay this message."
    call s:EchoHL('/dc[c] help', hlname)
    echo "\tDisplay a help message for DCC commands."
    echo "\n"
    call s:PromptEnter(0)
  catch /^Vim:Interrupt$/
  finally
    let &more = save_more
  endtry
endfunction

function! s:Cmd_DCCHELP(...)
  try
    let save_more = &more
    set more

    let hlname = 'Title'
    call s:EchoHL(' Available DCC commands:', hlname)
    echo "\n"
    call s:EchoHL('/dc[c] send [nick [file]]', hlname)
    echo "\tOffer DCC SEND to nick"
    call s:EchoHL('/dc[c] chat [nick]', hlname)
    echo "\tOffer DCC CHAT to, or accept pending offer from, nick"
    call s:EchoHL('/dc[c] get [nick [file]]', hlname)
    echo "\tAccept pending SEND offer from nick"
    call s:EchoHL('/dc[c] close [type [nick]]', hlname)
    echo "\tClose SEND/CHAT/GET connection with nick"
    call s:EchoHL('/dc[c] list', hlname)
    echo "\tList all active/pending DCC connections"
    echo "\n"
    call s:PromptEnter(0)
  catch /^Vim:Interrupt$/
  finally
    let &more = save_more
  endtry
endfunction

function! s:Cmd_REMOTEHELP(args)
  " XXX: Are there any servers who accept arguments?
  call s:DoSend('HELP', a:args)
endfunction

function! s:Cmd_WHOAMI(...)
  call s:EchoNormal('You are '.s:GetCurNick())
endfunction

"
" Misc. utility functions
"

" Generic ones

function! s:Beep(times)
  if a:times <= 0 || s:lastbeep >= localtime() - 1
    return
  endif

  try
    let errorbells = &errorbells
    let visualbell = &visualbell
    set errorbells
    set novisualbell

    let i = 1
    while i <= a:times
      call s:DoNormal("\<Esc>")
      call s:DoWait(a:times, i)
      let i = i + 1
    endwhile
  finally
    let &errorbells = errorbells
    let &visualbell = visualbell
    let s:lastbeep  = localtime()
  endtry
endfunction

function! s:ClearCommand(newline)
  echon "\r" (a:newline ? "\n" : '')
endfunction

function! s:EchoHL(mesg, hlname)
  try
    execute 'echohl' a:hlname
    echo a:mesg
  catch /^Vim:Interrupt$/
  finally
    echohl None
  endtry
endfunction

function! s:EchoError(mesg)
  call s:Beep(1)
  call s:HandlePromptKey(1, a:mesg, 'ErrorMsg')
endfunction

function! s:EchoNormal(mesg)
  call s:HandlePromptKey(1, a:mesg, 'Normal')
endfunction

function! s:EchoWarn(mesg)
  call s:HandlePromptKey(1, a:mesg, 'WarningMsg')
endfunction

function! s:Execute(comd, ...)
  let retval = 0
  if strlen(a:comd)
    let silent = (a:0 && a:1)
    try
      let retval = s:Execute{silent ? 'Silent' : 'Loud'}(a:comd)
    catch /^Vim:Interrupt$/
    endtry
  endif
  return retval
endfunction

function! s:ExecuteLoud(comd)
  let loud = 0
  call s:UntoggleCursor(1)
  try
    let save_more = &more
    let save_reg = @"

    let @" = @_
    set more

    redir @"
    execute a:comd
    redir END

    " XXX: Vim sometimes echoes just "\r\n"
    let loud = (strlen(@") && @" !~ '^[\r\n]\+$')
    if !loud && strlen(@")
      call s:RedrawScreen(0)
    endif
  finally
    let &more = save_more
    let @" = save_reg
    call s:UntoggleCursor(0)
  endtry
  return loud
endfunction

function! s:ExecuteSafe(prefix, comd)
  execute (exists(':'.a:prefix) == 2 ? a:prefix.' ' : '').a:comd
endfunction

function! s:ExecuteShell(comd)
  let comd = a:comd
  if &shellxquote == '"' && s:IsWin3264() && !match(a:comd, '^start ')
    " Remove unecessary escapes
    let comd = substitute(comd, '\\"\@=', '', 'g')
  endif
  call s:ExecuteSilent('!'.comd)
endfunction

function! s:ExecuteSilent(comd)
  let v:errmsg = ''
  silent! execute a:comd
  return !strlen(v:errmsg)
endfunction

function! s:DoInsert(append)
  execute 'startinsert'.(a:append ? '!' : '')
endfunction

function! s:DoIterate(ex, comd, times)
  let loud = 0
  if strlen(a:comd)
    let i = 1
    while i <= a:times
      if a:ex
	let loud = s:ExecuteLoud(a:comd)
      else
	call s:DoNormal(a:comd, 1)
      endif
      let i = i + 1
    endwhile
  endif
  return loud
endfunction

function! s:DoNormal(comd, ...)
  if strlen(a:comd)
    if !(a:0 && a:1)
      execute 'normal!' a:comd
    else
      call s:DoNormalSafe(a:comd)
    endif
  endif
endfunction

" Executes normal mode commands.  Do not try to make changes with this.
" NOTE: This can be slow if used repetitively
function! s:DoNormalSafe(comd)
  try
    let orgbuf = bufnr('%')
    let modifiable = &l:modifiable
    " Temporarily forbid user to tamper with the buffer.
    call setbufvar(orgbuf, '&modifiable', 0)
    execute 'normal!' a:comd
  finally
    call setbufvar(orgbuf, '&modifiable', modifiable)
  endtry
endfunction

function! s:DoWincmd(comd, ...)
  call s:ExecuteSilent((a:0 ? a:1 : '').'wincmd '.a:comd)
  return winnr()
endfunction

function! s:GetEnv(var)
  let var = expand(a:var)
  if var ==# a:var
    let var = ''
  endif
  return var
endfunction

function! s:GetTime(short, ...)
  return strftime((a:short ? '%H:%M' : '%Y/%m/%d %H:%M:%S'),
	\				    (a:0 && a:1 ? a:1 : localtime()))
endfunction

function! s:GetVimVar(varname)
  return exists('{a:varname}') ? {a:varname} : ''
endfunction

function! s:Read(file)
  let save_cpoptions = &cpoptions
  set cpoptions-=a
  if !&l:modifiable
    setlocal modifiable
  endif

  call s:ExecuteSilent('read '.a:file)
  1call s:DelLine()

  let &cpoptions = save_cpoptions
  return !s:IsBufEmpty()
endfunction

function! s:RedrawScreen(all)
  execute 'redraw'.(a:all ? '!' : '')
endfunction

function! s:RedrawStatus(...)
  call s:ExecuteSilent('redrawstatus'.(a:0 && a:1 ? '!' : ''))
endfunction

" Show user that she is in pending-mode
function! s:ShowCmd(comd)
  " Right-aligning the message
  echon s:StrMultiply(' ', (&columns - 20))
	\ strpart(a:comd, (strlen(a:comd) > 8 ? strlen(a:comd) - 8 : 0)) "\r"
endfunction

function! s:Write(file, append)
  " TODO: Range support
  if s:IsBufEmpty()
    return
  endif

  let save_cpoptions = &cpoptions
  set cpoptions-=A
  " Cannot write if it is loaded elsewhere
  call s:BufUnload(a:file)
  call s:ExecuteSilent('write! '.(a:append ? '>> ' : '').a:file)
  let &cpoptions = save_cpoptions
endfunction

" Interactive functions

function! s:Confirm(mesg, list)
  let choice = 0
  call s:UntoggleCursor(1)

  try
    let choice = confirm(a:mesg, a:list)
  catch /^Vim:Interrupt$/
  finally
    call s:RedrawScreen(0)
    call s:UntoggleCursor(0)
  endtry
  return choice
endfunction

function! s:Confirm_YN(mesg)
  return (s:PromptChar(20, ' '.a:mesg.'? (y/[n]): ', 'Question') ==? 'y')
endfunction

function! s:Input(mesg, ...)
  return s:DoInput(0, a:mesg.': ', (a:0 ? a:1 : ''))
endfunction

function! s:InputS(mesg)
  return s:DoInput(1, a:mesg.': ', '')
endfunction

function! s:DoInput(secret, mesg, text)
  let input = ''
  call s:UntoggleCursor(1)

  try
    let input = s:StrCompress(input{a:secret ? 'secret' : ''}(a:mesg, a:text))
  catch /^Vim:Interrupt$/
  finally
    call s:UntoggleCursor(0)
  endtry
  return input
endfunction

function! s:Key2Char(key)
  " Special keys (<F1> etc.) are char values already (f_getchar() in eval.c)
  return type(a:key) ? a:key : nr2char(a:key)
endfunction

function! s:GetChar(cursor)
  return s:Key2Char(s:GetKey(a:cursor))
endfunction

function! s:GetKey(cursor)
  let key = 0
  if a:cursor
    call s:UntoggleCursor(1)
  endif

  try
    let key = getchar()
  catch /^Vim:Interrupt$/
  finally
    call s:ClearCommand(0)
    if a:cursor
      call s:UntoggleCursor(0)
    endif
  endtry
  return key
endfunction

function! s:PromptChar(timeout, mesg, ...)
  return s:Key2Char(s:PromptKey(a:timeout, a:mesg, (a:0 ? a:1 : 'MoreMsg')))
endfunction

function! s:PromptEnter(timeout)
  call s:ClearCommand(1)
  call s:HandlePromptKey(a:timeout, 'Hit ENTER or type command to continue')
endfunction

function! s:PromptKey(timeout, mesg, ...)
  " TODO: Make timeout-length configurable
  let key = 0
  let hlname = a:0 ? a:1 : 'MoreMsg'

  call s:ClearCommand(0)
  if a:timeout > 0
    let key = s:PromptKeyTick(a:timeout, a:mesg, hlname)
  else
    call s:EchoHL(a:mesg, hlname)
    let key = s:GetKey(1)
  endif

  call s:ClearCommand(0)
  return key
endfunction

" PromptKey with timeout feature
function! s:PromptKeyTick(timeout, mesg, hlname)
  let key = 0

  try
    let startT = localtime()
    while (a:timeout - (s:DoTick(a:mesg, '\|/-', a:hlname) - startT)) > 0
      if getchar(1)
	let key = getchar(0)
	break
      endif
      call s:DoWait(1, 0)
    endwhile
  catch /^Vim:Interrupt$/
  endtry
  return key
endfunction

function! s:DoTick(mesg, ticker, ...)
  let nowT = localtime()
  try
    execute 'echohl' (a:0 ? a:1 : 'Normal')
    echon a:mesg
    execute 'echohl' s:hl_cursor
    echon a:ticker[nowT % strlen(a:ticker)] "\r"
  finally
    echohl None
  endtry
  return nowT
endfunction

" Sleep except for the final round
function! s:DoWait(final, round)
  if (a:final - a:round)
    sleep 250 m
  endif
endfunction

function! s:RequestFile(mesg)
  let fname = ''
  call s:UntoggleCursor(1)

  try
    let fname = has('browse') ? browse(0, 'Select file '.a:mesg, './', '')
	  \		      : input('Enter filename '.a:mesg.': ')
  catch /^Vim:Interrupt$/
  finally
    call s:UntoggleCursor(0)
  endtry
  return fname
endfunction

function! s:SearchWord(comd)
  let word = s:DoInput(0, a:comd, '')
  if strlen(word)
    let @/ = word
    call s:DoNormal((a:comd == '/' ? 'n' : 'N'))
  endif
endfunction

function! s:ConsumeKey()
  let key = getchar(0)
  while !s:IsZero(getchar(1))
    if !key
      call s:UnstickKey(1)
    endif
    call getchar(0)
  endwhile
  return key
endfunction

" KLUGE: Without this, special keys hit while in normal mode keep generating
" key codes by themselves, resulting in nearly 100% CPU-time consumption, or
" user-interaction impossibility (vim bug?)
function! s:UnstickKey(force)
  if a:force || !s:IsZero(getchar(1))
    silent! normal! lh
  endif
endfunction

" String manipulation

function! s:StrMatch(str, pat, sub)
  " A wrapper function to substitute().  First extract an interesting part
  " upon which we perform matching, so that only necessary string (sub) will
  " be obtained.  An empty string will be returned on failure.
  " I took this clever trick from Chalice.
  return substitute(matchstr(a:str, a:pat), a:pat, a:sub, '')
endfunction

function! s:StrQuote(str)
  let quote = (&shellxquote == '"' ? '\' : '').'"'
  return quote.a:str.quote
endfunction

" Remove unnecessary spaces in a string
function! s:StrTrim(str, ...)
  let space = (!a:0 || a:1 =~ '^ \=$')
  let patrn = space ? '\s' : '\%(\s*\V'.a:1.'\m\s*\)'

  let str = substitute(a:str, '[[:cntrl:]]\+', '', 'g')	" just in case
  let str = substitute(str, '\%(^'.patrn.'\+\|'.patrn.'\+$\)', '', 'g')
  return str
endfunction

" Ditto
function! s:StrCompress(str, ...)
  let space = (!a:0 || a:1 =~ '^ \=$')
  let patrn = space ? '\s' : '\%(\s*\V'.a:1.'\m\s*\)'
  let subst = space ? ' ' : a:1

  let str = s:StrTrim(a:str, subst)
  return substitute(str, patrn.'\+', subst, 'g')
endfunction

" Severer version of the above
function! s:StrSquash(str, ...)
  let space = (!a:0 || a:1 =~ '^ \=$')
  let patrn = space ? '\s' : '\%(\s*\V'.a:1.'\m\s*\)'

  return substitute(a:str, patrn.'\+', '', 'g')
endfunction

function! s:StrMultiply(from, times)
  " Super cool logic entirely copied from Chalice
  let to = ''
  let from = a:from
  let times = a:times
  while times
    if times % 2
      " This is binary addition in actuality, performed with strings
      let to = to.from
    endif
    let times = times / 2
    let from = from.from
  endwhile
  return to
endfunction

" Divide string at space or comma
function! s:StrDivide(str, group)
  return s:StrMatch(a:str,
	\	    '^\([^[:space:],]\+\)\=\%([[:space:],]\+\(.*\)\)\=$',
	\	    '\'.a:group)
endfunction

function! s:EscapeFName(str)
  return escape(a:str, '%#')
endfunction

function! s:EscapeMagic(str)
  return escape(a:str, '$*.\^~')
endfunction

function! s:EscapeQuote(str)
  return escape(a:str, '"\')
endfunction

" Confirmation functions

function! s:Is2KeyCmd(char)
  return (a:char =~# "^[zgftFTm`'@Z]$")
endfunction

function! s:IsCtrl_W(key)
  " Can accept both key code and char
  return (s:Key2Char(a:key) == "\<C-W>")
endfunction

function! s:IsWin3264()
  return (has('win32') || has('win32unix') || has('win64'))
endfunction

function! s:IsZero(num)
  " Evaluate it as string, since "a:num == 0" unexpectedly (?) evaluates to
  " true if a:num is a string value
  return (''.a:num == '0')
endfunction

" Validation functions

function! s:ValidatePath(path)
  let path = a:path
  if strlen(path)
    let path = fnamemodify(path, ':p')
    let path = substitute(path, '\', '/', 'g')
    let path = substitute(path, '/\{2,\}', '/', 'g')
    let path = substitute(path, '/$', '', '')
  endif
  return path
endfunction

function! s:ValidateURL(url)
  let url = a:url
  if strlen(a:url)
    " Cut the unnecessary tail, as in "http://www.foo.com/)."
    let url = substitute(a:url, '[),.:;>\]]\+$', '', '')
    if !s:IsServerIRC(url)
      " "www" stuff
      if url !~ '^\a\+://'
	let url = 'http://'.url
      endif
      " domain only, without the final slash
      if url =~ '^\a\+://[^/]\+$'
	let url = url.'/'
      endif
    endif
  endif
  return url
endfunction

" Line functions

function! s:SearchLine(line)
  return strlen(a:line) ? search('\m^'.s:EscapeMagic(a:line).'$', 'w') : 0
endfunction

function! s:DelLine() range
  call s:ExecuteSilent(a:firstline.','.a:lastline.'delete _')
endfunction

function! s:OpenNewLine()
  let lnum = '$'
  if strlen(getline(lnum))
    call append(lnum, '')
  endif
  call s:WinBottom(lnum)
endfunction

" Buffer functions

function! s:ExistsBufVar(bufnum, bufvar)
  return strlen(getbufvar(a:bufnum, a:bufvar))
endfunction

function! s:IsBufCurrent(bufnum)
  return (bufnr('%') == a:bufnum)
endfunction

function! s:IsBufEmpty()
  return !(line('$') > 1 || strlen(getline(1)))
endfunction

function! s:BufClear()
  if !s:IsBufEmpty()
    %call s:DelLine()
  endif
endfunction

function! s:BufClose(bufnum)
  let retval = 1
  if bufwinnr(a:bufnum) >= 0
    let &equalalways = 0

    while s:BufVisit(a:bufnum)
      if !s:ExecuteSilent('close!')
	let retval = 0
	break
      endif
    endwhile

    let &equalalways = 1
  endif
  return retval
endfunction

function! s:BufReverse()
  perl $curbuf->Set(1, reverse($curbuf->Get(1 .. $curbuf->Count())))
endfunction

function! s:BufTrim()
  while search('^\s*$', 'w') && line('$') > 1
    call s:DelLine()
  endwhile
endfunction

function! s:BufUnload(bufname)
  " If it is loaded in another buffer, unload it
  if bufloaded(a:bufname) && !s:IsBufCurrent(bufnr(a:bufname))
    call s:ExecuteSilent('bunload! '.a:bufname)
  endif
endfunction

function! s:BufVisit(bufnum)
  return (a:bufnum >= 0 && (  s:IsBufCurrent(a:bufnum)
	\		   || s:WinVisit(bufwinnr(a:bufnum))))
endfunction

" Window functions

function! s:WinClose(...)
  let retval = 1
  let winnum = a:0 ? a:1 : winnr()

  if s:WinVisit(winnum)
    let &equalalways = 0
    let retval = s:ExecuteSilent('close!')
    let &equalalways = 1
  endif
  return retval
endfunction

function! s:WinVisit(winnum)
  let curwin = winnr()
  if a:winnum >= 0 && curwin != a:winnum
    let curwin = s:DoWincmd('w', a:winnum)
  endif
  return (curwin == a:winnum)
endfunction

function! s:IsBottomVisible(offset)
  return (winheight(0) - winline() + a:offset >= line('$') - line('.'))
endfunction

if 1
function! s:WinBottom(...)
  call s:DoNormal('0zb')
  return a:0 ? s:WinLine(a:1) : line('.')
endfunction
else
function! s:WinBottom(...)
  if a:0
    call s:WinLine(a:1)
  endif
  call s:DoNormal('0zb')
  return line('.')
endfunction
endif

function! s:WinLine(lnum)
  " For safety, convert it to number if it isn't
  let lnum = a:lnum ? a:lnum : line(a:lnum)
  if lnum > 0 && line('.') != lnum
    execute lnum
  endif
  return line('.')
endfunction

function! s:WinResize(size, vertical)
  if a:size > 0
    execute (a:vertical ? 'vertical ' : '').'resize' a:size
  endif
endfunction

function! s:WinScroll(cnt)
  if a:cnt
    let org = line('.')
    let upw = (a:cnt < 0)
    let cnt = a:cnt * (upw ? -1 : 1)
    call s:DoNormal(cnt.nr2char(5 * (upw ? 5 : 1)))	" count <C-Y>/<C-E>
    call s:WinLine(org)
    call s:RedrawScreen(0)
  endif
endfunction

function! s:WinScroll2(lnum)
  " First, scroll to the specified line
  call s:WinBottom((type(a:lnum) || a:lnum > 0) ? a:lnum : '$')
  " Then make the bottom line visible, if possible
  while !s:IsBottomVisible(0) && winline() > 2
    cal s:DoNormal("\<C-E>")
  endwhile
endfunction

" Highlighting-related (no syntax-highlighting) stuffs

function! s:GetHilite(name, mode)
  return synIDattr(synIDtrans(hlID(a:name)), a:mode)
endfunction

function! s:SetHilite(name, fg, bg, ...)
  let mode= has('gui') ? 'gui' : 'cterm'
  let fg  = strlen(a:fg) ? a:fg : 'NONE'
  let bg  = strlen(a:bg) ? a:bg : 'NONE'
  let etc = (a:0 && strlen(a:1)) ? a:1 : 'NONE'

  execute 'highlight' (a:name) (mode.'='.etc) (mode.'fg='.fg) (mode.'bg='.bg)
endfunction

function! s:SetHlCursor()
  " TODO: Deal with colorscheme changes
  let hlname = 'Cursor'
  let s:hl_cursor = 'VimIRCCursor'

  let s:cursor_fg = s:GetHilite(hlname, 'fg')
  let s:cursor_bg = s:GetHilite(hlname, 'bg')
  if !(strlen(s:cursor_fg) || strlen(s:cursor_bg))
    let hlname = 'Visual'
    let s:cursor_fg = s:GetHilite(hlname, 'fg')
    let s:cursor_bg = s:GetHilite(hlname, 'bg')
  endif

  let s:cursor_etc = ''
  let etclist = 'bold,italic,reverse,underline'
  while strlen(etclist)
    let etc = s:StrDivide(etclist, 1)
    if s:GetHilite(hlname, etc)
      let s:cursor_etc = (strlen(s:cursor_etc) ? s:cursor_etc.',' : '').etc
    endif
    let etclist = s:StrDivide(etclist, 2)
  endwhile

  call s:SetHilite(s:hl_cursor, s:cursor_fg, s:cursor_bg, s:cursor_etc)
endfunction

function! s:ToggleCursor(hide)
  if hlexists('Cursor')
    call s:SetHilite('Cursor', (a:hide ? '' : s:cursor_fg),
	  \		       (a:hide ? '' : s:cursor_bg),
	  \		       (a:hide ? '' : s:cursor_etc))
  endif
endfunction

" Temporarily restores cursor for prompting
function! s:UntoggleCursor(show)
  if s:in_loop
    call s:ToggleCursor(!a:show)
  endif
endfunction

function! s:HiliteBuffer()
  call s:HiliteColumn(s:IsBufType_Info() ? 'DiffText' : s:hl_cursor)
endfunction

function! s:HiliteClear()
  match none
  " Clear command line incidentally
  if s:in_loop
    call s:ClearCommand(0)
  endif
endfunction

" Function calls should be as few as possible for better performance
function! s:HiliteColumn(...)
  silent! execute 'match' (a:0 ? a:1 : s:hl_cursor) '/\%#\s*\S*/'
  redraw
endfunction

function! s:HiliteLine(lnum, ...)
  silent! execute 'match' (a:0 ? a:1 : s:hl_cursor) '/\%'.s:WinLine(a:lnum).'l/'
  redraw
endfunction

function! s:HiliteURL(url)
  let patrn = substitute(a:url, '\%(^\a\+://\|/$\)', '', 'g')
  " Do you want to retain old highlights?
  if 1
    call s:ExecuteSilent('syntax clear VimIRCURL')
  endif
  call s:ExecuteSilent('syntax match VimIRCURL "\V'.patrn.'"')
  highlight link VimIRCURL DiffChange
endfunction

"
" And the Perl part
"

if has('perl')
function! s:MakeDir(dir)
  if isdirectory(a:dir)
    return 1
  endif

  perl <<EOP
{
  my_mkdir(scalar(VIM::Eval('a:dir')));
}
EOP
  return isdirectory(a:dir)
endfunction

function! s:SetEncoding()
  " The idea is, we should load & use conversion-related codes only if
  " necessary
  let ircenc = ''
  " TODO: Deal with encodings other than Japanese
  if strlen(s:preflang)
    let ircenc = s:preflang
  elseif &encoding =~# '\%(cp932\|euc-jp\)'
    let ircenc = '7bit-jis'
  else
    return
  endif

  perl <<EOP
{
  use Encode;

  $ENC_VIM = VIM::Eval('&encoding');
  $ENC_IRC = VIM::Eval('l:ircenc');
}
EOP
endfunction

function! s:SortList(cmp, dir)
  perl <<EOP
{
  my $cmp = VIM::Eval('a:cmp');
  my $dir = VIM::Eval('a:dir');
  my @lns = $curbuf->Get(1 .. $curbuf->Count());

  if ($cmp eq 'channel')
    {
      @lns = map { $_->[0] }
	      sort {  if ($dir) { lc($b->[1]) cmp lc($a->[1]) }
		      else	{ lc($a->[1]) cmp lc($b->[1]) } }
		map { [ $_, /^(\S+).*$/ ] } @lns;
    }
  elsif ($cmp eq 'member')
    {
      @lns = map { $_->[0] }
	      sort {  if ($dir) { $b->[1] <=> $a->[1] }
		      else	{ $a->[1] <=> $b->[1] } }
		map { [ $_, /^\S+\s+(\d+).*$/ ] } @lns;
    }
  else
    {
      @lns = map { $_->[0] }
	      sort {  if ($dir) { $b->[1] cmp $a->[1] }
		      else	{ $a->[1] cmp $b->[1] } }
		map { [ $_, /^\S+\s+\d+\s*(.*)$/ ] } @lns;
    }
  $curbuf->Set(1, @lns);
}
EOP
endfunction

function! s:PostLoadList(updated)
  let bufnum = s:GetBufNum_List()
  if a:updated
    call setbufvar(bufnum, 'updated', localtime())
  endif

  perl <<EOP
{
  unless (find_list($Current_Server))
    {
      $Current_Server->{'list'}->{'bufnum'} = VIM::Eval('l:bufnum');
      set_info($Current_Server, $INFO_UPDATE);
    }
}
EOP
  call setbufvar(bufnum, 'updating', 0)
endfunction

function! s:DoTimer()
  let lasttime = s:RecvData()
  if lasttime
    if lasttime <= s:lasttime
      " If lasttime is zero, i.e., the connection was lost, do NOT exit here:
      " we should update the infobar to mark the server as dead.
      return lasttime
    endif
    let s:lasttime = lasttime
  endif

  if s:current_changed
    call s:SetCurChanServ()
  endif

  perl <<EOP
{
  do_timer(scalar(VIM::Eval('s:lasttime')));
}
EOP
  call s:SetTitleBar(s:lasttime)
  call s:RedrawStatus(1)

  return lasttime
endfunction

function! s:QuitChat(nick)
  if !strlen(a:nick)
    return
  endif

  perl <<EOP
{
  del_chat(scalar(VIM::Eval('a:nick')), $Current_Server);
}
EOP
endfunction

function! s:DelChanServ()
  let abuf = expand('<abuf>') + 0
  call s:DelBufNum(abuf)
  if !s:IsBufType_ChanServ(abuf)
    return
  endif
  let channel= getbufvar(abuf, 'channel')
  let server = getbufvar(abuf, 'server')

  perl <<EOP
{
  my $chan = VIM::Eval('l:channel');
  my $serv = VIM::Eval('l:server');

  if (my ($cref, $sref) = find_chanserv($chan, $serv))
    {
      if ($cref->{'bufnum'} >= 0)
	{
	  $cref->{'bufnum'} = -1;
	  set_info($sref, $INFO_UPDATE);
	}
    }
}
EOP
endfunction

function! s:SetCurChanServ()
  let bufnum = bufnr('%')
  if !s:IsBufType_ChanServ(bufnum)
    return
  endif

  perl <<EOP
{
  my $bufnum = VIM::Eval('l:bufnum');

  if ($Current_ChanServ != $bufnum)
    {
      $Current_ChanServ = $bufnum;
      set_info($Current_Server, $INFO_UPDATE);
      VIM::DoCommand('if s:in_loop|call s:HiliteBuffer()|endif');
    }
}
EOP
  let s:current_changed = 0
endfunction

function! s:ResetCurChanServ(channel, server, ...)
  perl <<EOP
{
  my $chan = VIM::Eval('a:channel');
  my $serv = VIM::Eval('a:server');
  my $donick = VIM::Eval('a:0 && a:1');

  my ($cref, $sref) = find_chanserv($chan, $serv);
  if ($cref)
    {
      set_curserver($sref->{'sock'});

      if (has_info($cref, $INFO_HASNEW))
	{
	  set_info($sref, $INFO_UPDATE);
	  unset_info($cref, $INFO_HASNEW);
	}

      if (is_chan($chan) && (has_info($cref, $INFO_UPDATE) || $donick))
	{
	  draw_nickwin($chan);
	  unset_info($cref, $INFO_UPDATE);
	}
    }
}
EOP
  let s:current_changed = 1
endfunction

" NOTE: This is a tricky function written solely for ease of typing: you
" (developer) can omit `server' argument for some functions even if you should
" provide one.  So, don't forget to call this when necessary so that vimirc
" will not get confused about which server should be addressed to.
function! s:SetCurServer(server, ...)
  if a:0
    call s:SetCurChannel(a:1)
  endif

  perl <<EOP
{
  if (my $sref = find_server(scalar(VIM::Eval('a:server'))))
    {
      set_curserver($sref->{'sock'});
    }
}
EOP
endfunction

function! s:SetCurChannel(channel)
  let s:channel = s:IsList(a:channel) ? '' : a:channel
endfunction

function! s:GetBufNum_Next(forward, cnt)
  let bufnum = 0

  perl <<EOP
{
  my @chanserv;
  my $orgbuf = vim_bufnr();

  foreach my $sref (@Servers)
    {
      if ($sref->{'bufnum'} >= 0)
	{
	  unshift(@chanserv, $sref->{'bufnum'});
	}

      if (my $lref = find_list($sref))
	{
	  unshift(@chanserv, $lref->{'bufnum'});
	}

      foreach my $cref (@{$sref->{'chans'}})
	{
	  if ($cref->{'bufnum'} >= 0)
	    {
	      unshift(@chanserv, $cref->{'bufnum'});
	    }
	}
      foreach my $cref (@{$sref->{'chats'}})
	{
	  if ($cref->{'bufnum'} >= 0)
	    {
	      unshift(@chanserv, $cref->{'bufnum'});
	    }
	}
    }

  if ($#chanserv >= 0)
    {
      my $first = $chanserv[0];
      my $next	= $first;
      my $count = VIM::Eval('a:cnt') % scalar(@chanserv);

      if ($#chanserv > 0 && $count)
	{

	  if (VIM::Eval('a:forward'))
	    {
	      @chanserv = reverse(@chanserv);
	      $first = $chanserv[0];
	    }

	  # Find the position of $orgbuf
	  if ($first != $orgbuf)
	    {
	      while ($chanserv[0] != $orgbuf)
		{
		  push(@chanserv, shift(@chanserv));
		  # $orgbuf wasn't in the list
		  if ($chanserv[0] == $first)
		    {
		      last;
		    }
		}
	    }
	  $next = $chanserv[$count];
	}

      VIM::DoCommand("let bufnum = $next");
    }
}
EOP
  return bufnum
endfunction

function! s:GetCurNick(...)
  perl <<EOP
{
  my $nick;
  my $sref = VIM::Eval('a:0') ? find_server(scalar(VIM::Eval('a:1')))
			      : $Current_Server;

  if (exists($sref->{'nick'}) && $sref->{'nick'})
    {
      $nick = $sref->{'nick'};
    }
  else
    {
      $nick = vim_getvar('s:nick');
    }

  VIM::DoCommand('return "'.do_escape($nick).'"');
}
EOP
endfunction

function! s:IsConnected(...)
  let retval = 0
  let server = a:0 ? a:1 : s:server
  if !s:IsServer(server)
    return retval
  endif

  perl <<EOP
{
  if (my $sref = find_server(scalar(VIM::Eval('l:server'))))
    {
      VIM::DoCommand('let retval = '.($sref->{'conn'} & $CS_LOGIN));
    }
}
EOP
  return retval
endfunction

function! s:IsSockOpen()
  perl <<EOP
{
  if (defined($RS))
    {
      VIM::DoCommand('return '.$RS->count());
    }
}
EOP
  return 0
endfunction

function! s:RecvData()
  let retval = localtime()

  perl <<EOP
{
  # XXX: We're not using $WS currently, due to the blocking issue of syswrite
  my ($r, $w) = IO::Select->select($RS, $WS, undef, 0.2);
  my $sock;

  foreach $sock (@{$w})
    {
      dcc_check($sock, 1);
    }

  foreach $sock (@{$r})
    {
      unless (dcc_check($sock))
	{
	  unless (irc_recv($sock))
	    {
	      unless ($RS->count())
		{
		  VIM::DoCommand('let retval = 0');
		  last;
		}
	    }
	}
    }
}
EOP
  return retval
endfunction

function! s:Cmd_SERVER(server)
  let server = strlen(a:server) ? a:server : s:GetVimVar('b:server')
  let port = 0
  let pass = ''

  if !strlen(server)
    let server = s:Input('Enter server name')
  endif

  " TODO: Validity check of server?
  let rx = '^\(..\{-\}\)\%(:\(\d\+\)\)\=\%(\s\+\(\S\+\)\)\=$'
  if server !~ rx
    return
  endif

  let s:server = tolower(s:StrMatch(server, rx, '\1'))
  let port = s:StrMatch(server, rx, '\2') + 0
  let pass = s:StrMatch(server, rx, '\3')

  if !port
    let port = getbufvar(s:GetBufNum_Server(), 'port') + 0
    if port <= 0
      let port = 6667
    endif
  endif

  call s:OpenBuf_Server(port)
  call s:CloseWin_DeadServer()

  perl <<EOP
{
  my $server= VIM::Eval('s:server');
  my $port  = VIM::Eval('l:port');
  my $nick  = VIM::Eval('s:GetCurNick()');
  my $pass  = VIM::Eval('l:pass');

  cmd_server($server, $port, $nick, $pass);
}
EOP
endfunction

function! s:Send_ACTION(comd, args)
  perl <<EOP
{
  if (my ($chan, $mesg) = (VIM::Eval('a:args') =~ /^(\S+)\s+:(.+)$/))
    {
      my $comd = VIM::Eval('a:comd');

      unless (index($chan, '='))
	{
	  dcc_send_chat(substr($chan, 1), sprintf("\x01%s %s\x01",
							      $comd, $mesg));
	}
      else
	{
	  my $nick = $Current_Server->{'nick'};

	  ctcp_send(1, $chan, "%s %s", $comd, $mesg);

	  if (is_chan($chan))
	    {
	      irc_chan_line($chan, "*%s%s*: %s",
				    find_nickprefix($nick, $chan),
				    $nick, $mesg);
	    }
	  else
	    {
	      irc_chat_line($chan, "*%s*: %s", $nick, $mesg);
	    }
	}
    }
}
EOP
endfunction

function! s:Send_AWAY(comd, args)
  perl <<EOP
{
  my $comd = VIM::Eval('a:comd');

  if (my ($mesg) = (VIM::Eval('a:args') =~ /^:(.+)$/))
    {
      $Current_Server->{'away'} = $mesg;
      irc_send("%s :%s", $comd, $mesg);
    }
  elsif ($Current_Server->{'away'})
    {
      $Current_Server->{'away'} = undef;
      irc_send("%s", $comd);
    }
}
EOP
endfunction

function! s:Send_CTCP(comd, args)
  perl <<EOP
{
  if (my ($to, $comd, $args) = (VIM::Eval('a:args')
					    =~ /^(\S+)\s+(\S+)(?:\s+(.+))?$/))
    {
      $comd = uc($comd);

      if ($comd eq 'PING')
	{
	  $args = time();
	}

      unless (is_chan($to))	# sending ctcp to channel is rude except ACTION
	{
	  ctcp_send(1, $to, "%s%s", $comd, ($args ? " $args" : ""));
	}
    }
}
EOP
endfunction

function! s:Send_DCC(comd, args)
  " /DCC SEND nick file
  let type = 'LIST'
  let nick = ''
  let desc = ''

  let rx = '^\(\S\+\)\%(\s\+\(\S\+\)\%(\s\+\(.\+\)\)\=\)\=$'
  if a:args =~ rx
    let type = toupper(s:StrMatch(a:args, rx, '\1'))
    if type ==# 'HELP'
      return s:Cmd_DCCHELP()
    elseif type =~# '^\%(CLOSE\|SEND\|GET\|CHAT\)$'
      let nick = s:StrMatch(a:args, rx, '\2')
      let desc = s:StrMatch(a:args, rx, '\3')

      if !strlen(nick)
	let nick = s:Input('Specify the peer nickname')
	if !strlen(nick)
	  return
	endif
      endif
      if type ==# 'SEND'
	if !strlen(desc)
	  let desc = s:RequestFile('to upload')
	endif
	let desc = s:ValidatePath(desc)
	if !filereadable(desc)
	  return s:EchoError('File '.desc.' not available')
	endif
      endif
    endif
  endif

  perl <<EOP
{
  cmd_dcc(scalar(VIM::Eval('l:type')),
	  scalar(VIM::Eval('l:nick')),
	  scalar(VIM::Eval('l:desc')));
}
EOP
endfunction

function! s:Send_DESCRIBE(comd, args)
  call s:Send_ACTION('ACTION', a:args)
endfunction

function! s:Send_GAWAY(comd, args)
  call s:SendGlobally('AWAY', a:args)
endfunction

function! s:Send_GQUIT(comd, args)
  call s:SendGlobally('QUIT', a:args)
endfunction

function! s:Send_JOIN(comd, args)
  " It's possible to do "/join 0,#newchan", to quit all current channels, and
  " newly join the specified channel after that.
  perl <<EOP
{
  my $chans = VIM::Eval('a:args');

  if (my ($chans, $keys) = ($chans =~ /^(\S+)(?:\s+(\S+))?$/))
    {
      my @chans = split(/,/, $chans);
      my @keys  = split(/,/, $keys);

      foreach my $chan (@chans)
	{
	  my $key;
	  if (is_chan($chan))
	    {
	      $key = shift(@keys);
	      vim_open_chan($chan);

	      if (find_chan($chan))
		{
		  next;
		}
	      else
		{
		  add_chan($chan, $key);
		}
	    }
	  irc_send("JOIN %s%s", $chan, ($key ? " $key" : ""));
	}
    }
}
EOP
endfunction

function! s:Send_LIST(comd, args)
  " MEMO: Some servers don't send "321 RPL_LISTSTART", so open a list buffer
  " before we send the command
  if s:LoadList()
    return s:PostLoadList(0)
  endif

  perl <<EOP
{
  my $comd = VIM::Eval('a:comd');
  my $args = VIM::Eval('a:args');

  unset_info($Current_Server->{'list'}, $INFO_LINE1);
  irc_send("%s%s", $comd, ($args ? " $args" : ""));
}
EOP
endfunction

function! s:Send_NAMES(comd, args)
  perl <<EOP
{
  my $comd  = VIM::Eval('a:comd');
  my $chans = VIM::Eval('a:args');

  if ($chans)
    {
      foreach my $chan (split(/,/, $chans))
	{
	  if (is_chan($chan))
	    {
	      if (find_chan($chan))
		{
		  init_nicks($chan);
		}
	      irc_send("%s %s", $comd, $chan);
	    }
	}
    }
  else
    {
      irc_send("%s", $comd);
    }
}
EOP
endfunction

function! s:Send_NICK(comd, args)
  " TODO: Warn user if she currently has active query (chat) sessions
  let nick = a:args
  if !strlen(a:args)
    let nick = s:Input('Enter a new nickname')
    if !strlen(nick)
      return
    endif
  endif

  call s:DoSend(a:comd, nick)
endfunction

function! s:Send_PART(comd, args)
  " XXX: According to RFC1459, PART command only accepts channels.
  let args = strlen(a:args) ? a:args : (s:IsChannel(s:channel)
	\				? s:channel.' '.s:partmsg : '')
  if !strlen(args)
    return
  endif

  perl <<EOP
{
  my ($chans, $mesg) = (VIM::Eval('l:args') =~ /^(\S+)(?:\s+(.+))?$/);

  foreach my $chan (split(/,/, $chans))
    {
      if (is_chan($chan))
	{
	  irc_send("PART %s%s", $chan, ($mesg ? " $mesg" : ""));
	}
    }
}
EOP
  " XXX: Without this, nick/command windows for the channel could remain open.
  " Perhaps CursorHold event cancels BufHidden?  Well, let us look into the
  " source (TODO).
  call s:MainLoop()
endfunction

function! s:Send_PING(comd, args)
  if !strlen(a:args) || s:IsChannel(a:args)
    return
  endif

  perl <<EOP
{
  ctcp_send(1, scalar(VIM::Eval('a:args')), "%s %d",
					    scalar(VIM::Eval('a:comd')),
					    time());
}
EOP
endfunction

function! s:Send_QUIT(comd, args)
  let mesg = strlen(a:args) ? a:args : s:partmsg

  perl <<EOP
{
  my $mesg = VIM::Eval('l:mesg');

  # $mesg itself already contains a leading colon
  irc_send("QUIT %s", $mesg);

  foreach my $cref (@{$Current_Server->{'chans'}})
    {
      vim_close_chan($cref->{'name'});
    }

  foreach my $cref (@{$Current_Server->{'chats'}})
    {
      vim_close_chat($cref->{'nick'}, $Current_Server->{'server'});
    }

  while (my $dcc = find_dccclient())
    {
      dcc_close($dcc);
    }

  $Current_Server->{'conn'} |= $CS_QUIT;
}
EOP
  call s:CloseBuf_Server()
endfunction

function! s:Send_NOTICE(comd, args)
  call s:SendMSG(a:comd, a:args)
endfunction

function! s:Send_PRIVMSG(comd, args)
  call s:SendMSG(a:comd, a:args)
endfunction

function! s:SendGlobally(comd, args)
  perl <<EOP
{
  my $save_cur = $Current_Server;

  foreach my $sref (@Servers)
    {
      if ($sref->{'conn'} & $CS_LOGIN)
	{
	  set_curserver($sref->{'sock'});
	  VIM::DoCommand('call s:Send_{a:comd}(a:comd, a:args)');
	}
    }
  set_curserver($save_cur->{'sock'});
}
EOP
endfunction

function! s:SendMSG(comd, args)
  if !strlen(a:args)
    return
  endif

  perl <<EOP
{
  if (my ($chans, $mesg) = (VIM::Eval('a:args') =~ /^(\S+) :(.+)$/))
    {
      unless (index($chans, '='))  # DCC CHAT
	{
	  dcc_send_chat(substr($chans, 1), $mesg);
	}
      else
	{
	  # According to RFC1459, NOTICE doesn't accept multiple receivers,
	  # On dancer-ircd (freenode etc.), PRIVMSG doesn't either.
	  my $priv;
	  my $comd = VIM::Eval('a:comd');
	  my $nick = $Current_Server->{'nick'};

	  unless ($comd)
	    {
	      $comd = 'PRIVMSG';
	    }
	  $priv = ($comd eq 'PRIVMSG');

	  irc_send("%s %s :%s", $comd, $chans, $mesg);

	  foreach my $chan (split(/,/, $chans))
	    {
	      if (is_chan($chan))
		{
		  irc_chan_line($chan, "%s%s%s%s: %s",
					($priv ? '<' : '['),
					find_nickprefix($nick, $chan),
					$nick,
					($priv ? '>' : ']'),
					$mesg);
		}
	      else
		{
		  irc_chat_line($chan, "%s%s%s: %s",
					($priv ? '<' : '['),
					$nick,
					($priv ? '>' : ']'),
					$mesg);
		}
	    }
	}
    }
}
EOP
endfunction

function! s:DoSend(comd, args)
  perl <<EOP
{
  my $comd = VIM::Eval('a:comd');
  my $args = VIM::Eval('a:args');

  irc_send("%s%s", $comd, ($args ? " $args" : ""));
}
EOP
endfunction

function! s:ResetPerlVars()
  perl <<EOP
{
  undef @Servers;
  undef %Clients;
  undef $Current_Server;
  undef $Current_ChanServ;
  undef $RS;
  undef $WS;
}
EOP
endfunction

function! s:PerlIRC()
  " Don't use strict
  " TODO: Put these things in separate files
  perl <<EOP

use Fcntl qw(O_RDONLY O_WRONLY O_CREAT O_EXCL O_APPEND O_TRUNC);

our @Servers;		# IRC servers
our $Current_Server;	# reference referring an element of @Servers
our $Current_ChanServ;	# buffer number of the active channel/server

our %Clients;		# clients connected over dcc protocol
our ($RS, $WS);		# IO::Select objects

our $From_Server;	# simple string value of the last sender's name@host

our ($ENC_VIM, $ENC_IRC);

# Connection state flags
our $CS_LOGIN = 0x01;	# successfully logged in
our $CS_RECON = 0x02;	# trying to reconnect (after disconnected by server)
our $CS_QUIT  = 0x04;	# user "/QUIT"ted

sub add_server
{
  my $sref =  { server	  => undef,
		port	  => 0,
		local	  => undef,
		sock	  => undef,
		conn	  => 0,
		info	  => 0,
		bufnum	  => -1,
		nick	  => undef,
		pass	  => undef,
		umode	  => undef,
		away	  => undef,
		motd	  => 0,
		chans	  => [],
		chats	  => [],
		timers	  => [],
		lastping  => time(),
		lastbuf   => undef,
		lines	  => []
	      };

  add_list($sref);
  push(@Servers, $sref);
  return $sref;
}

sub find_server
{
  my $server = shift;

  foreach my $sref (@Servers)
    {
      if ($server eq $sref->{'server'})
	{
	  return $sref;
	}
    }

  return undef;
}

sub set_connected
{
  if ($_[0])
    {
      # Leave CS_RECON flag untouched.  It'll be used to supress motd message
      $Current_Server->{'conn'} &= ~$CS_QUIT;
      $Current_Server->{'conn'} |= $CS_LOGIN;
    }
  else
    {
      close_server($Current_Server);
    }
  set_info($Current_Server, $INFO_UPDATE);
}

sub close_server
{
  if (my $sref = shift)
    {
      $sref->{'conn'}  &= ~$CS_LOGIN;
      $sref->{'motd'}   = 0;
      $sref->{'lastbuf'}= undef;

      if ($sref->{'conn'} & $CS_QUIT)
	{
	  @{$sref->{'timers'}} = ();
	}

      conn_close($sref);
    }
}

sub open_server
{
  my $sref = shift;

  if (conn_open($sref))
    {
      conn_watchin($sref);  # add it to IO::Select
      #$sref->{'local'} = $sref->{'sock'}->sockhost();
      login_server($sref);
      return 1;
    }

  irc_chan_line('', "!: Could not establish connection: %s", $!);
  return 0;
}

sub cmd_server
{
  my ($server, $port, $nick, $pass) = @_;

  if ($port <= 0)
    {
      $port = 6667;
    }

  unless ($pass)
    {
      $pass = VIM::Eval('s:GetServerPASS()');
    }

  if ($Current_Server = find_server($server))
    {
      if (($Current_Server->{'conn'} & $CS_LOGIN)
					&& $Current_Server->{'port'} == $port)
	{
	  return;
	}
      close_server($Current_Server);
    }
  else
    {
      if ($Current_Server = add_server())
	{
	  $Current_Server->{'server'} = $server;
	  $Current_Server->{'nick'}   = $nick;
	}
    }

  if ($Current_Server)
    {
      $Current_Server->{'port'} = $port;
      unless ($Current_Server->{'umode'})
	{
	  $Current_Server->{'umode'} = vim_get_serverumode();
	}
      if ($pass)
	{
	  $Current_Server->{'pass'} = $pass;
	}
      open_server($Current_Server);
    }
}

sub login_server
{
  my $sref = shift;

  if ($Current_Server != $sref)
    {
      $Current_Server = $sref;
    }

  if ($sref->{'pass'})
    {
      irc_send("PASS %s", $sref->{'pass'});
    }
  irc_send("NICK %s", $sref->{'nick'});
  irc_send("USER %s %s %s :%s",
	    vim_getvar('s:user'),
	    vim_get_serverumode(),
	    vim_getvar('s:user'),
	    vim_getvar('s:realname'));
}

sub post_login_server
{
  my $sref = shift;

  $sref->{'motd'} = 1;
  $sref->{'conn'} &= ~$CS_RECON;  # clear the "reconnecting" flag

  irc_send("USERHOST %s", $sref->{'nick'});

  if ($sref->{'umode'})
    {
      irc_send("MODE %s %s", $sref->{'nick'}, $sref->{'umode'});
    }

  if ($sref->{'away'})
    {
      irc_send("AWAY :%s", $sref->{'away'});
    }

  if (@{$sref->{'chans'}})
    {
      # Re-join channels
      foreach my $cref (@{$sref->{'chans'}})
	{
	  my $args = [ "JOIN %s%s", $cref->{'name'}, $cref->{'key'}
						      ? " $cref->{'key'}"
						      : "" ];
	  add_timer(2, \&irc_send, $args);
	}
    }
  else
    {
      # Wait a few seconds so that you join channels (hopefully) after
      # auto-identifying the nick
      add_timer(2, \&do_auto_join);
    }
}

sub conn_close
{
  my $sref = shift;

  if ($sref->{'sock'})
    {
      $RS->remove($sref->{'sock'});

      if (defined($WS) && $WS->exists($sref->{'sock'}))
	{
	  $WS->remove($sref->{'sock'});
	}

      #$sref->{'sock'}->shutdown(2);
      $sref->{'sock'}->close();
    }
}

sub conn_open
{
  use IO::Socket;

  my $sref = shift;
  my $sock;

  if ($sref->{'server'} && $sref->{'port'})
    {
      $sock = IO::Socket::INET->new(PeerAddr  => $sref->{'server'},
				    PeerPort  => $sref->{'port'},
				    Proto     => 'tcp',
				    Timeout   => 10);
      if ($sock)
	{
	  $sref->{'sock'} = $sock;
	}
    }

  return defined($sock);
}

sub conn_watchin
{
  my $sref = shift;

  if (defined($sref->{'sock'}))
    {
      unless (defined($RS))
	{
	  use IO::Select;
	  $RS = IO::Select->new();
	}
      $RS->add($sref->{'sock'});
    }
}

sub conn_watchout
{
  my $sref = shift;

  if (defined($sref->{'sock'}))
    {
      unless (defined($WS))
	{
	  $WS = IO::Select->new();
	}
      $WS->add($sref->{'sock'});
    }
}

sub set_curserver
{
  my $sock = shift;

  foreach my $sref (@Servers)
    {
      if ($sock == $sref->{'sock'})
	{
	  $Current_Server = $sref;
	  VIM::DoCommand("let s:server = \"$sref->{'server'}\"");
	  last;
	}
    }
}

sub has_lines
{
  my $cref = shift;

  return (exists($cref->{'lines'}) && @{$cref->{'lines'}});
}

sub put_all_lines
{
  my $sref = shift;

  if (has_lines($sref))
    {
      put_serv_lines($sref);
    }

  if (has_lines($sref->{'list'}))
    {
      put_list_lines($sref->{'list'});
    }

  foreach my $cref (@{$sref->{'chans'}})
    {
      if (has_lines($cref))
	{
	  put_chan_lines($cref);
	}
    }

  foreach my $cref (@{$sref->{'chats'}})
    {
      if (has_lines($cref))
	{
	  put_chat_lines($cref, $sref);
	}
    }
}

sub put_serv_lines
{
  my $sref = shift;
  my ($orgw, $peek) = pre_put_lines('serv');
  do_put_lines($sref, $peek);
  post_put_lines($sref, $orgw, $peek);
}

sub put_list_lines
{
  my $lref = shift;
  my ($orgw, $peek) = pre_put_lines('list');
  do_put_lines($lref, $peek);

  unless (has_info($lref, $INFO_LINE1))
    {
      $curbuf->Delete(1);
      set_info($lref, $INFO_LINE1);
    }
  post_put_lines($lref, $orgw, $peek);
}

sub put_chan_lines
{
  my $cref = shift;
  my ($orgw, $peek) = pre_put_lines('chan', [ $cref->{'name'} ]);
  do_put_lines($cref, $peek);
  post_put_lines($cref, $orgw, $peek);
}

sub put_chat_lines
{
  my ($cref, $sref) = @_;
  my ($orgw, $peek) = pre_put_lines('chat', [ $cref->{'nick'},
					      $sref->{'server'} ]);
  do_put_lines($cref, $peek);
  post_put_lines($cref, $orgw, $peek);
}

sub pre_put_lines
{
  my ($type, $args) = @_;
  my $orgw = vim_winnr();
  my $peek = !&{'vim_visit_'.$type}(@{$args});

  if ($peek)
    {
      vim_peekbuf(0);
      &{'vim_open_'.$type}(@{$args});
    }
  return ($orgw, $peek);
}

sub do_put_lines
{
  my ($cref, $peek) = @_;
  # Shouldn't scroll down nor beep while you're away
  my $notify = !($peek || $Current_Server->{'away'} || is_list($cref));

  vim_modifybuf(1);

  if ($notify)
    {
      foreach my $line (@{$cref->{'lines'}})
	{
	  $curbuf->Append($curbuf->Count(), $line);
	  VIM::DoCommand("call s:NotifyNewEntry(0)");
	}
    }
  else
    {
      $curbuf->Append($curbuf->Count(), @{$cref->{'lines'}});
    }
  vim_modifybuf(0);
}

sub post_put_lines
{
  my ($cref, $orgw, $peek) = @_;

  if ($cref->{'bufnum'} < 0)
    {
      # I sometimes see this fail
      $cref->{'bufnum'} = vim_bufnr();
      set_info($Current_Server, $INFO_UPDATE);
    }

  if ($peek)
    {
      unless (has_info($cref, $INFO_HASNEW))
	{
	  set_info($cref, $INFO_HASNEW);
	  set_info($Current_Server, $INFO_UPDATE);
	}
      vim_peekbuf($orgw);
    }
  else
    {
      vim_winvisit($orgw);
    }

  @{$cref->{'lines'}} = ();
}

sub irc_push_line
{
  my $cref = shift;
  my $args = shift;
  my $form = shift(@{$args});

  return push(@{$cref->{'lines'}}, sprintf("%s $form", vim_gettime(1),
								  @{$args}));
}

sub irc_chan_line
{
  my $chan = shift;
  my $cref = is_chan($chan) ? find_chan($chan) : undef;

  unless ($cref)
    {
      $cref = $Current_Server;
    }

  if (irc_push_line($cref, \@_) >= 10)
    {
      &{'put_'.($cref == $Current_Server ? 'serv' : 'chan').'_lines'}($cref);
    }
}

sub irc_chat_line
{
  my $nick = shift;
  my $cref = find_chat($nick, $Current_Server);

  unless ($cref)
    {
      $cref = add_chat($nick, $Current_Server);
    }

  if (irc_push_line($cref, \@_) >= 10)
    {
      put_chat_lines($cref, $Current_Server);
    }
}

sub irc_list_line
{
  my $lref = $Current_Server->{'list'};

  if (push(@{$lref->{'lines'}}, sprintf("%-22s %5d %s", @_)) >= 30)
    {
      put_list_lines($lref);
    }
}

sub irc_recv
{
  my $sock = shift;
  my ($buffer, @lines);

  set_curserver($sock);

  unless (sysread($sock, $buffer, 2048))
    {
      set_connected(0);

      unless ($Current_Server->{'conn'} & $CS_QUIT)
	{
	  $Current_Server->{'conn'} |= $CS_RECON;
	  irc_chan_line('', "!: Connection with %s lost",
						  $Current_Server->{'server'});
	  irc_chan_line('', "*: Reconnecting...");

	  if (open_server($Current_Server))
	    {
	      return 1;
	    }
	}
      return 0;
    }

  if ($Current_Server->{'lastbuf'})
    {
      $buffer = $Current_Server->{'lastbuf'}.$buffer;
      $Current_Server->{'lastbuf'} = undef;
    }

  if ($ENC_VIM && $ENC_IRC)
    {
      Encode::from_to($buffer, $ENC_IRC, $ENC_VIM);
      $buffer =~ s/\\x([[:xdigit:]]{2})/pack('H2', $1)/eg;
      $buffer =~ s/\\x\{([[:xdigit:]]{4})\}/pack('H4', $1)/eg;
    }

  @lines = split(/\x0D?\x0A/, $buffer);
  if (substr($buffer, -1) ne "\x0A")
    {
      # Data obtained partially. Save the last line for later use
      $Current_Server->{'lastbuf'} = pop(@lines);
    }

  foreach my $line (@lines)
    {
      if (0)
	{
	  vim_printf($line);
	}
      parse_line(\$line);
    }

  return 1;
}

sub irc_send
{
  my $form = shift;
  my @args = @_;

  if ($ENC_VIM && $ENC_IRC)
    {
      foreach my $arg (@args)
	{
	  Encode::from_to($arg, $ENC_VIM, $ENC_IRC);
	}
    }
  syswrite($Current_Server->{'sock'}, sprintf("$form\x0D\x0A", @args));
}

#
# Infobar
#

our $INFO_UPDATE = 0x01;
our $INFO_HASNEW = 0x02;
our $INFO_LINE1	 = 0x04;

sub update_info
{
  my $orgw = vim_winnr();
  # TODO: Preserve previous window (?)

  if (my $opened = vim_open_info())
    {
      my ($orgln) = $curwin->Cursor();

      vim_modifybuf(1);
      $curbuf->Delete(1, $curbuf->Count());

      foreach my $sref (@Servers)
	{
	  my $dead = !($sref->{'conn'} & $CS_LOGIN);

	  $curbuf->Append($curbuf->Count(),
			  sprintf("%s[%d]%s",
				  is_current($sref)
				    ? '*'
				    : has_info($sref, $INFO_HASNEW)
					? '+'
					: $dead ? '-' : ' ',
				  $sref->{'bufnum'},
				  $sref->{'server'}));

	  if (my $lref = find_list($sref))
	    {
	      $curbuf->Append($curbuf->Count(),
			      sprintf(" %s[%d]*list\t\t\t%s",
				      is_current($lref)
					? '*'
					: has_info($lref, $INFO_HASNEW)
					  ? '+'
					  : $dead ? '-' : ' ',
				      $lref->{'bufnum'},
				      $sref->{'server'}));
	    }

	  foreach my $cref (@{$sref->{'chans'}})
	    {
	      $curbuf->Append($curbuf->Count(),
			      sprintf(" %s[%d]%s\t\t\t%s",
				      is_current($cref)
					? '*'
					: has_info($cref, $INFO_HASNEW)
					    ? '+'
					    : $dead ? '-' : ' ',
				      $cref->{'bufnum'},
				      $cref->{'name'},
				      $sref->{'server'}));
	    }

	  foreach my $cref (@{$sref->{'chats'}})
	    {
	      $curbuf->Append($curbuf->Count(),
			      sprintf(" %s[%d]%s\t\t\t%s",
				      is_current($cref)
					? '*'
					: has_info($cref, $INFO_HASNEW)
					    ? '+'
					    : $dead
					      && index($cref->{'nick'}, '=')
						? '-' : ' ',
				      $cref->{'bufnum'},
				      $cref->{'nick'},
				      $sref->{'server'}));
	    }

	  unset_info($sref, $INFO_UPDATE);
	}

      $curbuf->Delete(1);
      if ($orgln)
	{
	  $curwin->Cursor($orgln, 0);
	}
      vim_modifybuf(0);
      vim_winvisit($orgw + ($opened < 0));
    }
}

sub has_info
{
  my ($sref, $info) = @_;

  return (exists($sref->{'info'}) && ($sref->{'info'} & $info));
}

sub set_info
{
  my ($sref, $info) = @_;

  if (exists($sref->{'info'}) && !($sref->{'info'} & $info))
    {
      $sref->{'info'} |= $info;
    }
}

sub unset_info
{
  my ($sref, $info) = @_;

  if (exists($sref->{'info'}) && ($sref->{'info'} & $info))
    {
      $sref->{'info'} &= ~$info;
    }
}

# Make it noticeable that a hidden channel has got a new message
#sub refresh_chans
#{
#  my ($chans, $cref) = @_;
#
#  while ($chans->[0] != $cref)
#    {
#      push(@{$chans}, shift(@{$chans}));
#    }
#}

#
# Timer
#

sub add_timer
{
  my ($secs, $func, $args) = @_;
  my $timer;

  if (my $timers = $Current_Server->{'timers'})
    {
      $timer =	{ time => time() + $secs,
		  func => $func,
		  args => $args,
		  done => 0
		};
      push(@{$timers}, $timer);
    }

  return $timer;
}

sub del_timer
{
  foreach my $sref (@Servers)
    {
      for (my $i = 0; $i <= $#{$sref->{'timers'}}; $i++)
	{
	  if ($sref->{'timers'}->[$i]->{'done'})
	    {
	      splice(@{$sref->{'timers'}}, $i--, 1);
	    }
	}
    }
}

sub do_timer
{
  my $time = shift;
  my $did  = 0;
  my $info = 0;

  my $save_cur = $Current_Server;

  foreach my $sref (@Servers)
    {
      set_curserver($sref->{'sock'});
      put_all_lines($sref);

      if ($sref->{'conn'} & $CS_LOGIN)
	{
	  do_auto_ping($sref, $time);
	  do_auto_away($sref, $time);

	  foreach my $timer (@{$sref->{'timers'}})
	    {
	      if ($timer->{'time'} <= $time)
		{
		  $timer->{'func'}(@{$timer->{'args'}});
		  $timer->{'done'} = 1;
		  $did++;
		}
	    }
	}

      unless ($info)
	{
	  $info = has_info($sref, $INFO_UPDATE);
	}
    }

  if ($did)
    {
      del_timer();
    }
  if ($info)
    {
      update_info();
    }
  set_curserver($save_cur->{'sock'});
}

sub do_auto_away
{
  my ($sref, $time) = @_;

  if (!$sref->{'away'} && vim_getvar('s:autoaway'))
    {
      my $lastactive = vim_getvar('s:lastactive');

      if ($time >= $lastactive + vim_getvar('s:autoawaytime'))
	{
	  irc_chan_line('', "*: Auto-awaying...");
	  $sref->{'away'} = sprintf("I think I'm gone (been idle since %s).",
						  vim_gettime(0, $lastactive));
	  irc_send("AWAY :%s", $sref->{'away'});
	}
    }
}

# Play ping-pong with servers to keep connected
sub do_auto_ping
{
  my ($sref, $time) = @_;

  if ($time >= $sref->{'lastping'} + 90)
    {
      irc_send("PING %d", $time);
      $sref->{'lastping'} = $time;
    }
}

sub do_auto_join
{
  VIM::DoCommand('call s:DoAutoJoin()');
}

#
# CTCP
#

# Heavily based on ircii and x-chat, regarding the DCC part.

our @DCC_TYPES = qw(. GET SEND CHAT CHAT);

our $DCC_FILERECV = 0x01;
our $DCC_FILESEND = 0x02;
our $DCC_CHATRECV = 0x03;
our $DCC_CHATSEND = 0x04;
our $DCC_TYPE	  = 0x0f;

our $DCC_RESUME	  = 0x10;
our $DCC_QUEUED	  = 0x20;
our $DCC_ACTIVE	  = 0x40;
our $DCC_FAILED	  = 0x80;

our $DCC_BLOCK_SIZE = 2048;

sub ctcp_send
{
  # TODO: Follow the rules described in:
  #   "REVISED AND UPDATED CTCP SPECIFICATION"
  #   Dated Fri, 12 Aug 94 00:21:54 edt
  #   By ben@gnu.ai.mit.edu et al.
  my $query = shift;
  my $target= shift;

  irc_send("%s %s :\x01%s\x01", ($query ? 'PRIVMSG' : 'NOTICE'), $target,
						      sprintf(shift(@_), @_));
}

sub ctcp_query_action
{
  my ($from, $pref, $chan, $mesg) = @_;

  if (is_chan($chan))
    {
      irc_chan_line($chan, "*%s%s*: %s", $pref, $from, ${$mesg});
    }
  elsif (is_me($chan))
    {
      irc_chat_line($from, "*%s*: %s", $from, ${$mesg});
      vim_beep(1);
    }
}

sub ctcp_query_clientinfo
{
  my ($from, $comd, $args) = @_;
  our %info;

  unless (defined(%info))
    {
      %info = (
	     CLIENTINFO => 'gives information about available CTCP commands',
		ECHO	=> 'returns arguments you send',
		PING	=> 'returns arguments you send',
		TIME	=> 'tells you the time on my side',
		VERSION => 'shows client type and version'
	      );
    }

  unless ($args)
    {
      ctcp_send(0, $from, "%s %s. Use %s <COMMAND> to get more specific
			\ information", $comd, join(' ', keys(%info)), $comd);
    }
  else
    {
      $args = uc($args);

      if (exists($info{$args}))
	{
	  ctcp_send(0, $from, "%s %s", $comd, $info{$args});
	}
      else
	{
	  ctcp_send(0, $from, "%s No such function implemented: %s",
								$comd, $args);
	}
    }
}

sub ctcp_query_echo
{
  ctcp_send(0, $_[0], "%s %s", $_[1], $_[2]);
}

sub ctcp_query_ping
{
  ctcp_send(0, $_[0], "%s %s", $_[1], $_[2]);
}

sub ctcp_query_time
{
  ctcp_send(0, $_[0], "%s %s", $_[1], vim_gettime(0));
}

sub ctcp_query_version
{
  ctcp_send(0, $_[0], "%s %s", $_[1], vim_getvar('s:client'));
}

sub process_ctcp_query
{
  my ($from, $pref, $chan, $mesg) = @_;

  while (${$mesg} =~ s/\x01(.*?)\x01//)
    {
      # TODO: flood-protection codes here
      if (my ($comd, $args) = ($1 =~ /^(\S+)(?:\s+(.+))?$/))
	{
	  if ($comd eq 'DCC')
	    {
	      if (is_me($chan))   # is this check necessary?
		{
		  process_dcc_query($from, $args);
		}
	    }
	  elsif ($comd eq 'ACTION')
	    {
	      ctcp_query_action($from, $pref, $chan, \$args);
	    }
	  else
	    {
	      my $func = 'ctcp_query_'.lc($comd);

	      irc_chan_line($chan, "?%s%s(CTCP)?: %s %s", $pref, $from, $comd,
									$args);

	      if (defined(&{$func}))
		{
		  &{$func}($from, $comd, $args);
		}
	      else
		{
		  if (is_me($chan))
		    {
		      ctcp_send(0, $from, "ERRMSG %s: unknown query", $comd);
		    }
		  irc_chan_line('', "!: CTCP query from %s unprocessed: %s",
								$from, $comd);
		}
	    }
	}
    }

  return length(${$mesg});
}

sub process_ctcp_reply
{
  my ($from, $chan, $mesg) = @_;

  if (${$mesg} =~ s/\x01(.*?)\x01//)
    {
      if (my ($comd, $args) = ($1 =~ /^(\S+)(?:\s+(.+))?$/))
	{
	  if ($comd eq 'DCC')
	    {
	      if (is_me($chan))
		{
		  process_dcc_reply($from, $args);
		}
	    }
	  elsif ($comd eq 'PING')
	    {
	      my $diff = time() - $args;
	      irc_chan_line('', "[%s(%s)]: %d second%s delay",
				$from, $comd, $diff, ($diff != 1 ? 's' : ''));
	    }
	  else
	    {
	      irc_chan_line('', "[%s(%s)]: %s", $from, $comd, $args);
	    }
	}
    }
  return length(${$mesg});
}

sub process_dcc_query
{
  my ($from, $args) = @_;

  if (1)
    {
      irc_chan_line('', "?%s(DCC)?: %s", $from, $args);
    }

  # Hope no one includes spaces in filenames
  if (my ($type, $desc, $server, $port, $size) =
		    ($args =~ /^(\S+)\s+(\S+)\s+(\S+)\s+(\d+)(?:\s+(\d+))?$/))
    {
      my $dcc;

      if ($type eq 'RESUME')
	{
	  # NOTE: resumes don't have a `server' part
	  dcc_they_resume($from, $desc, $server, $port);
	  return;
	}
      elsif ($type eq 'ACCEPT')
	{
	  dcc_i_resume($from, $desc, $server, $port);
	  return;
	}

      # TODO: IPv6
      if (index($server, '.') <= 0)   # XXX: could it be in dotted-quad form?
	{
	  $server = inet_ntoa(pack('N', $server));
	}

      if ($type eq 'CHAT')
	{
	  $dcc = find_dccclient($from, $DCC_CHATRECV);
	  if ($dcc)
	    {
	      dcc_close($dcc);
	    }
	  $dcc = find_dccclient($from, $DCC_CHATSEND);
	  if ($dcc)
	    {
	      dcc_close($dcc);
	    }

	  $dcc = add_dccclient();
	  if ($dcc)
	    {
	      $dcc->{'nick'}  = $from;
	      $dcc->{'server'}= $server;
	      $dcc->{'port'}  = $port;
	      $dcc->{'state'} = $DCC_CHATRECV;
	      $dcc->{'desc'}  = $desc;
	    }
	}
      elsif ($type eq 'SEND')
	{
	  $dcc = find_dccclient($from, $DCC_FILERECV, $desc);
	  if ($dcc)
	    {
	      return;
	    }

	  $dcc = add_dccclient();
	  if ($dcc)
	    {
	      my $dccdir = vim_getvar('s:dccdir');
	      my ($fname)= ($desc =~ m#^(?:.*/)?(.+)$#);

	      $dcc->{'nick'}  = $from;
	      $dcc->{'server'}= $server;
	      $dcc->{'port'}  = $port;
	      $dcc->{'state'} = $DCC_FILERECV;
	      $dcc->{'desc'}  = $desc;
	      $dcc->{'fname'} = sprintf("%s/%s", $dccdir, do_urldecode($fname));
	      $dcc->{'fsize'} = $size;

	      # FIXME: Currently turning off the RESUME: append seems to
	      # corrupt data
	      if (0 && -e $dcc->{'fname'})
		{
		  if ((my $fsize = (-s $dcc->{'fname'})) < $size)
		    {
		      # Need confirmation?
		      $dcc->{'state'} |= ($DCC_RESUME | $DCC_QUEUED);
		      $dcc->{'bytesread'} = $fsize;
		      ctcp_send(1, $dcc->{'nick'}, "DCC RESUME %s %d %d",
						    $desc, $port, $fsize);
		      return;
		    }
		}
	    }
	}
      else
	{
	  irc_chan_line('', "DCC: Query from %s unprocessed: %s", $from, $args);
	  ctcp_send(0, $from, "DCC REJECT %s %s", $type, $desc);
	}

      if ($dcc)
	{
	  $dcc->{'state'} |= $DCC_QUEUED;
	  dcc_open($dcc);
	}
    }
}

sub process_dcc_reply
{
  my ($from, $args) = @_;

  if (my ($type, $desc) = ($args =~ /^(\S+)\s+(.+)$/))
    {
      dcc_was_rejected($from, uc($type), $desc);
    }
  else
    {
      irc_chan_line('', "DCC: Reply from %s: %s", $from, $args);
    }
}

sub is_dcc_type
{
  my ($dcc, $type) = @_;

  return (exists($dcc->{'state'}) && ($dcc->{'state'} & $DCC_TYPE) == $type);
}

sub dcc_ask_accept_offer
{
  my $dcc  = shift;
  my $mesg = sprintf("%s is offering DCC %s to you.  Accept it",
		      $dcc->{'nick'},
		      (is_dcc_type($dcc, $DCC_FILERECV)
			? 'SEND'
			: $DCC_TYPES[$dcc->{'state'} & $DCC_TYPE]));

  vim_beep(2);
  return vim_confirm($mesg);
}

sub dcc_show_list
{
  irc_chan_line('', "*: Listing DCC sessions...");

  foreach my $sref (@Servers)
    {
      if (exists($Clients{$sref->{'server'}})
	  && @{$Clients{$sref->{'server'}}})
	{
	  irc_chan_line('', "DCC(LIST): * Via %s:", $sref->{'server'});
	  foreach my $dcc (@{$Clients{$sref->{'server'}}})
	    {
	      irc_chan_line('', "DCC(LIST): %-5s %-10.10s (%s) %7u/%-7u %s",
				$DCC_TYPES[$dcc->{'state'} & $DCC_TYPE],
				$dcc->{'nick'},
				(($dcc->{'state'} & $DCC_ACTIVE)
				  ? 'active'
				  : ($dcc->{'state'} & $DCC_QUEUED)
				    ? 'queued'
				    : 'closed'),
				($dcc->{'bytessent'}
				  ? $dcc->{'bytessent'}
				  : $dcc->{'bytesread'}),
				$dcc->{'fsize'},
				$dcc->{'fname'});
	    }
	}
    }
  irc_chan_line('', "End of /DCC LIST");
}

sub dcc_was_rejected
{
  my ($nick, $type, $desc) = @_;

  for (my $i = 1; $i < $#DCC_TYPES; $i++)
    {
      if ($type eq $DCC_TYPES[$i])
	{
	  $type = $i;
	}
    }

  unless ($type & $DCC_TYPE)
    {
      return;
    }

  if (my $dcc = find_dccclient($nick, $type, $desc))
    {
      irc_chan_line('', "DCC(%s): Offering %s to %s was rejected",
			$DCC_TYPES[$dcc->{'state'} & $DCC_TYPE],
			$desc,
			$nick);
      dcc_close($dcc);
    }
}

sub dcc_change_nicks
{
  my ($old, $new) = @_;

  # XXX: Why while?  I don't remember
  while (my $dcc = find_dccclient($old))
    {
      $dcc->{'nick'} = $new;
    }
}

sub dcc_parse_line
{
  my ($cref, $dcc, $itsme) = @_;

  foreach my $line (split(/\x0D?\x0A/, $dcc->{'linebuf'}))
    {
      my $action = ($line =~ s/^\x01ACTION (.*?)\x01/$1/);

      if ($ENC_VIM && $ENC_IRC)
	{
	  Encode::from_to($line, $ENC_IRC, $ENC_VIM);
	}
      if (irc_push_line($cref, [ "%s%s%s: %s",
				  ($action ? '*' : '='),
				  ($itsme
				    ? $dcc->{'iserver'}->{'nick'}
				    : $dcc->{'nick'}),
				  ($action ? '*' : '='),
				  $line ]) >= 10)
	{
	  put_chat_lines($cref, $dcc->{'iserver'});
	}
    }
}

sub dcc_chat_line
{
  my ($dcc, $itsme) = @_;
  my $cref = find_chat("=$dcc->{'nick'}", $dcc->{'iserver'});

  dcc_parse_line($cref, $dcc, $itsme);

  unless ($itsme)
    {
      vim_beep(1);
    }
}

sub add_dccclient
{
  # To avoid nick collisions, we hold dcc clients on server basis
  my $server = $Current_Server->{'server'};
  my $dcc = { nick	=> undef,
	      iserver	=> $Current_Server,
	      server	=> undef,
	      port	=> 0,
	      sock	=> undef,
	      state	=> 0,
	      desc	=> undef,
	      fh	=> undef,
	      fname	=> undef,
	      fsize	=> 0,
	      linebuf	=> undef,
	      lastbuf	=> undef,
	      bytesread => 0,
	      bytessent => 0,
	      starttime => 0,
	      lasttime	=> 0
	    };

  unless (exists($Clients{$server}))
    {
      $Clients{$server} = [];
    }

  unshift(@{$Clients{$server}}, $dcc);
  return $dcc;
}

sub find_dccclient_fd
{
  my $sock = shift;

  foreach my $sref (@Servers)
    {
      unless (exists($Clients{$sref->{'server'}}))
	{
	  next;
	}

      foreach my $dcc (@{$Clients{$sref->{'server'}}})
	{
	  if ($sock == $dcc->{'sock'})
	    {
	      return $dcc;
	    }
	}
    }

  return undef;
}

sub find_dccclient
{
  # An empty argument will be used as a wildcard (i.e., matches anything)
  # NOTE: Only clients on the current IRC server will be searched, since this
  # will only be called upon queries via that server
  my ($nick, $type, $desc) = @_;

  foreach my $dcc (@{$Clients{$Current_Server->{'server'}}})
    {
      if ($dcc->{'state'} & $DCC_FAILED)  # do not return closed/rejected one
	{
	  next;
	}
      if ($nick && $dcc->{'nick'} ne $nick)
	{
	  next;
	}
      if ($type && !is_dcc_type($dcc, $type))
	{
	  next;
	}
      if ($desc && $dcc->{'desc'} ne $desc)
	{
	  next;
	}
      return $dcc;
    }

  return undef;
}

sub del_dccclient
{
  my $dcc = shift;

  foreach my $sref (@Servers)
    {
      if (exists($Clients{$sref->{'server'}}))
	{
	  my $clients = $Clients{$sref->{'server'}};

	  for (my $i = 0; $i <= $#{$clients}; $i++)
	    {
	      if ($dcc == $clients->[$i])
		{
		  splice(@{$clients}, $i, 1);
		  return;
		}
	    }
	}
    }
}

sub dcc_init_listen
{
  my $dcc  = shift;
  # local address in unsigned long integer
  my $local= unpack('N', inet_aton($Current_Server->{'local'}));
  # port to watch at (normally 0)
  my $port = vim_getvar('s:dccport') + 0;
  my $ctcp;

  # Open up a listening socket
  $dcc->{'sock'} = IO::Socket::INET->new( LocalAddr => undef,
					  LocalPort => $port,
					  Proto	    => 'tcp',
					  Listen    => 1,
					  ReuseAddr => 1    );
  unless ($dcc->{'sock'})
    {
      del_dccclient($dcc);
      irc_chan_line('', "DCC(%s): Failed in opening socket: %s",
			$DCC_TYPES[$dcc->{'state'} & $DCC_TYPE], $!);
      return;
    }

  $dcc->{'port'} = $port ? $port : $dcc->{'sock'}->sockport();

  if (is_dcc_type($dcc, $DCC_FILESEND))
    {
      ctcp_send(1, $dcc->{'nick'}, "DCC %s %s %lu %u %ld",
				    $DCC_TYPES[$dcc->{'state'} & $DCC_TYPE],
				    $dcc->{'desc'},
				    $local,
				    $dcc->{'port'},
				    $dcc->{'fsize'});
    }
  else
    {
      ctcp_send(1, $dcc->{'nick'}, "DCC %s chat %lu %u",
				    $DCC_TYPES[$dcc->{'state'} & $DCC_TYPE],
				    $local,
				    $port);
    }
  conn_watchin($dcc);
}

sub dcc_i_accept
{
  my $dcc  = shift;
  my $sock = $dcc->{'sock'}->accept();

  unless ($sock)
    {
      irc_chan_line('', "DCC(%s): Could not accept incoming connect from %s: %s",
			$DCC_TYPES[$dcc->{'state'} & $DCC_TYPE],
			$dcc->{'nick'},
			$!);
      dcc_close($dcc);
      return;
    }

  conn_close($dcc);
  #$sock->sockopt(SO_SNDLOWAT, $DCC_BLOCK_SIZE);
  $dcc->{'sock'} = $sock;
  $dcc->{'server'} = $sock->peerhost();
  conn_watchin($dcc);
  $dcc->{'state'} &= ~$DCC_QUEUED;
  $dcc->{'state'} |= $DCC_ACTIVE;

  irc_chan_line('', "DCC(%s): Connection with %s established",
		    $DCC_TYPES[$dcc->{'state'} & $DCC_TYPE],
		    $dcc->{'nick'});

  if (is_dcc_type($dcc, $DCC_FILESEND))
    {
      # FIXME: it blocks
      #conn_watchout($dcc);
      dcc_send_file($dcc);
    }
  elsif (is_dcc_type($dcc, $DCC_CHATSEND))
    {
      # Drop the `send' flag off
      $dcc->{'state'} = ($DCC_CHATRECV | $DCC_ACTIVE);
    }

  if (is_dcc_type($dcc, $DCC_CHATRECV))
    {
      vim_open_chat("=$dcc->{'nick'}", $dcc->{'iserver'}->{'server'});
    }
}

sub dcc_they_accept
{
  my $dcc = shift;

  if (conn_open($dcc))
    {
      $dcc->{'state'} &= ~$DCC_QUEUED;
      $dcc->{'state'} |= $DCC_ACTIVE;

      if (is_dcc_type($dcc, $DCC_CHATRECV))
	{
	  add_chat("=$dcc->{'nick'}", $dcc->{'iserver'});
	}

      conn_watchin($dcc);
    }
  else
    {
      irc_chan_line('', "DCC(%s): Could not initialize connection with %s: %s",
			$DCC_TYPES[$dcc->{'state'} & $DCC_TYPE],
			$dcc->{'nick'}, $!);
      del_dccclient($dcc);
    }
}

sub dcc_open
{
  my $dcc = shift;

  unless ($dcc->{'state'})
    {
      # Huh?
      del_dccclient($dcc);
      return;
    }

  if (is_dcc_type($dcc, $DCC_FILESEND) || is_dcc_type($dcc, $DCC_CHATSEND))
    {
      dcc_init_listen($dcc);
    }
  else
    {
      if (($dcc->{'state'} & $DCC_RESUME) || dcc_ask_accept_offer($dcc))
	{
	  dcc_they_accept($dcc);
	}
    }
}

sub dcc_close
{
  my ($dcc, $destroy) = @_;

  conn_close($dcc);

  if ($dcc->{'fh'})
    {
      close($dcc->{'fh'});
    }

  # XXX: Delete it right now?  Or should we wait a few seconds?
  if (!defined($destroy) || $destroy)
    {
      if (is_dcc_type($dcc, $DCC_CHATRECV) || is_dcc_type($dcc, $DCC_CHATSEND))
	{
	  del_chat("=$dcc->{'nick'}", $dcc->{'iserver'});
	}
      del_dccclient($dcc);
    }
  else
    {
      $dcc->{'state'} &= ~$DCC_ACTIVE;
    }
}

sub dcc_i_resume
{
  my ($nick, $desc, $port, $resume) = @_;
  my $dcc = find_dccclient($nick, $DCC_FILERECV, $desc);

  if ($dcc && ($dcc->{'state'} & $DCC_QUEUED))
    {
      dcc_open($dcc);
    }
}

sub dcc_they_resume
{
  my ($nick, $desc, $port, $resume) = @_;
  my $dcc = find_dccclient($nick, $DCC_FILESEND, $desc);

  if ($dcc && ($dcc->{'port'} == $port) && ($resume < $dcc->{'fsize'}))
    {
      $dcc->{'bytessent'} = $resume;
      ctcp_send(1, $dcc->{'nick'}, "DCC ACCEPT %s %d %d", $desc, $port,
								    $resume);
    }
}

sub dcc_recv_file
{
  my $dcc = shift;
  my ($buffer, $bytesread);

  unless ($dcc->{'fh'})
    {
      my $dccdir = vim_getvar('s:dccdir');

      unless (my_mkdir($dccdir))
	{
	  irc_chan_line('', "DCC(GET): Could not create download directory: %s",
									  $!);
	  dcc_close($dcc);
	  return;
	}

      if ($dcc->{'state'} & $DCC_RESUME)
	{
	  sysopen($dcc->{'fh'}, $dcc->{'fname'}, O_BINARY|O_WRONLY|O_APPEND);
	}
      else
	{
	  if (-e $dcc->{'fname'})
	    {
	      my $n = 0;
	      my $newname = $dcc->{'fname'};
	      while (-e $newname)
		{
		  $newname = sprintf("%s.%d", $dcc->{'fname'}, ++$n);
		}
	      $dcc->{'fname'} = $newname;
	      irc_chan_line('', "DCC(GET): File already exists.
				\  Saving it as %s", $newname);
	    }
	  sysopen($dcc->{'fh'}, $dcc->{'fname'},
					    O_BINARY|O_WRONLY|O_EXCL|O_CREAT);
	}

      unless ($dcc->{'fh'})
	{
	  irc_chan_line('', "DCC(GET): Could not open file %s for writing:
			    \ %s", $dcc->{'fname'}, $!);
	  dcc_close($dcc);
	  return;
	}
    }

  unless ($bytesread = sysread($dcc->{'sock'}, $buffer, $DCC_BLOCK_SIZE))
    {
      if ($dcc->{'bytesread'} < $dcc->{'fsize'})
	{
	  irc_chan_line('', "DCC(GET): Connection with %s lost", $dcc->{'nick'});
	}
      dcc_close_filetransfer($dcc);
    }
  else
    {
      unless (syswrite($dcc->{'fh'}, $buffer, $bytesread))  # hdd full?
	{
	  irc_chan_line('', "DCC(GET): Failed in writing to file: %s", $!);
	  dcc_close($dcc);
	}
      else
	{
	  # Notify the progress to the peer
	  $dcc->{'bytesread'} += $bytesread;
	  unless (syswrite($dcc->{'sock'}, pack('N', $dcc->{'bytesread'}), 4))
	    {
	      irc_chan_line('', "DCC(GET): Connection with %s lost",
							      $dcc->{'nick'});
	      dcc_close($dcc);
	    }
	}
    }
}

sub dcc_recv_ack
{
  my $dcc = shift;
  my $ack;

  if (sysread($dcc->{'sock'}, $ack, 4) < 4)
    {
      irc_chan_line('', "DCC(SEND): Connection with %s lost", $dcc->{'nick'});
      dcc_close($dcc);
    }
  else
    {
      if ($dcc->{'bytessent'} >= $dcc->{'fsize'})
	{
	  if (unpack('N', $ack) >= $dcc->{'fsize'})
	    {
	      dcc_close_filetransfer($dcc);
	    }
	}
      else
	{
	  dcc_send_file($dcc);
	}
    }
}

sub dcc_send_file
{
  my $dcc = shift;
  my ($buffer, $bytesread);

  unless ($dcc->{'fh'})
    {
      if (sysopen($dcc->{'fh'}, $dcc->{'fname'}, O_BINARY|O_RDONLY))
	{
	  if ($dcc->{'bytessent'})
	    {
	      use Fcntl qw(SEEK_SET);
	      sysseek($dcc->{'fh'}, $dcc->{'bytessent'}, SEEK_SET);
	    }
	}
      else
	{
	  irc_chan_line('', "DCC(SEND): Could not open file for reading: %s",
									  $!);
	  dcc_close($dcc);
	  return;
	}
    }

  if ($bytesread = sysread($dcc->{'fh'}, $buffer, $DCC_BLOCK_SIZE))
    {
      # FIXME: It blocks if called via $WS
      if (syswrite($dcc->{'sock'}, $buffer, $bytesread) < $bytesread)
	{
	  irc_chan_line('', "DCC(SEND): Connection with %s lost",
							    $dcc->{'nick'});
	  dcc_close($dcc);
	}
      else
	{
	  $dcc->{'bytessent'} += $bytesread;
	}
    }
}

sub dcc_close_filetransfer
{
  my $dcc = shift;

  irc_chan_line('', "DCC(%s): Transfer of %s with %s completed (%d/%d)",
		    $DCC_TYPES[$dcc->{'state'} & $DCC_TYPE],
		    $dcc->{'desc'},
		    $dcc->{'nick'},
		    ($dcc->{'bytessent'}
		      ? $dcc->{'bytessent'}
		      : $dcc->{'bytesread'}),
		    $dcc->{'fsize'});
  dcc_close($dcc);
}

sub dcc_recv_chat
{
  my $dcc = shift;

  if (my $bytesread = sysread($dcc->{'sock'}, $dcc->{'linebuf'}, 1024))
    {
      $dcc->{'bytesread'} += $bytesread;

      if ($dcc->{'lastbuf'})
	{
	  $dcc->{'linebuf'} = $dcc->{'lastbuf'}.$dcc->{'linebuf'};
	  $dcc->{'lastbuf'} = undef;
	}

      if (substr($dcc->{'linebuf'}, -1) ne "\x0A")
	{
	  # irssi sends "\n" separately after sending a message line.  Why?
	  $dcc->{'lastbuf'} = $dcc->{'linebuf'};
	}
      else
	{
	  dcc_chat_line($dcc);
	}
    }
  else
    {
      irc_chan_line('', "DCC(CHAT): Connection with %s lost", $dcc->{'nick'});
      dcc_close($dcc);
    }
}

sub dcc_send_chat
{
  my ($nick, $mesg) = @_;
  my $dcc = find_dccclient($nick, $DCC_CHATRECV);

  if ($dcc->{'state'} & $DCC_ACTIVE)
    {
      if ($ENC_VIM && $ENC_IRC)
	{
	  Encode::from_to($mesg, $ENC_VIM, $ENC_IRC);
	}

      $dcc->{'linebuf'} = sprintf("%s\x0D\x0A", $mesg);
      if (my $bytessent = syswrite($dcc->{'sock'}, $dcc->{'linebuf'}))
	{
	  $dcc->{'bytessent'} += $bytessent;
	  dcc_chat_line($dcc, 1);
	}
    }
}

sub dcc_check
{
  my ($sock, $write) = @_;
  my $dcc = find_dccclient_fd($sock);

  unless ($dcc)
    {
      return 0;
    }

  if ($write)
    {
      if (is_dcc_type($dcc, $DCC_FILESEND))
	{
	  # We don't take much care about user acknowledgement
	  dcc_send_file($dcc);
	}
    }
  else
    {
      if (($dcc->{'state'} & $DCC_QUEUED) && (is_dcc_type($dcc, $DCC_FILESEND)
					   || is_dcc_type($dcc, $DCC_CHATSEND)))
	{
	  dcc_i_accept($dcc);
	}
      else
	{
	  if (is_dcc_type($dcc, $DCC_FILERECV))
	    {
	      dcc_recv_file($dcc);
	    }
	  elsif (is_dcc_type($dcc, $DCC_FILESEND))
	    {
	      # Pity we have to wait for a user ack before sending out
	      dcc_recv_ack($dcc);
	    }
	  elsif (is_dcc_type($dcc, $DCC_CHATRECV))
	    {
	      # MEMO: `send' flag must have already been dropped off
	      dcc_recv_chat($dcc);
	    }
	}
    }
  return 1;
}

sub cmd_dcc
{
  my ($type, $nick, $desc) = @_;
  my $dcc;

  if ($type eq 'CLOSE')
    {
      # /dcc close type [nick]
      $type = uc($nick);
      $nick = $desc;
      # Hmm, can't specify files

      if ($type)
	{
	  for (my $i = 1; $i < $#DCC_TYPES; $i++)
	    {
	      if ($type eq $DCC_TYPES[$i])
		{
		  $type = $i;
		  last;
		}
	    }
	  unless ($type & $DCC_TYPE)
	    {
	      $type = 0;
	    }
	}

      while ($dcc = find_dccclient($nick, $type, $desc))
	{
	  dcc_close($dcc);
	}
      return;
    }
  elsif ($type eq 'LIST')
    {
      dcc_show_list();
      return;
    }
  elsif ($type eq 'GET')
    {
      $dcc = find_dccclient($nick, $DCC_FILERECV, $desc);
      if ($dcc && ($dcc->{'state'} & $DCC_ACTIVE))
	{
	  return;
	}
    }
  elsif ($type eq 'SEND')
    {
      if ($dcc = find_dccclient($nick, $DCC_FILESEND, $desc))
	{
	  # already active or in queue
	  return;
	}
      else
	{
	  if ($dcc = add_dccclient())
	    {
	      my ($fname) = ($desc =~ m#^(?:.*/)?(.+)$#);

	      $dcc->{'nick'}  = $nick;
	      $dcc->{'state'} = $DCC_FILESEND;
	      $dcc->{'desc'}  = do_urlencode($fname);
	      $dcc->{'fname'} = $desc;
	      $dcc->{'fsize'} = (-s $desc);
	    }
	}
    }
  elsif ($type eq 'CHAT')
    {
      # Reuse already connected one, if found
      if ($dcc = find_dccclient($nick, $DCC_CHATSEND))
	{
	  # it must already be in queue on the peer side
	  return;
	}
      else
	{
	  unless ($dcc = find_dccclient($nick, $DCC_CHATRECV))
	    {
	      if ($dcc = add_dccclient())
		{
		  $dcc->{'nick'} = $nick;
		  $dcc->{'state'}= $DCC_CHATSEND;
		  $dcc->{'desc'} = lc($type);

		  add_chat("=$dcc->{'nick'}", $dcc->{'iserver'});
		}
	    }
	}
    }

  if ($dcc)
    {
      if ($dcc->{'state'} & $DCC_QUEUED)
	{
	  dcc_they_accept($dcc);
	}
      elsif (!($dcc->{'state'} & $DCC_ACTIVE))
	{
	  $dcc->{'state'} |= $DCC_QUEUED;
	  dcc_open($dcc);
	}
    }
}

#
# Channel management
#

our $UMODE_VOICE  = 0x01;
our $UMODE_CHOP	  = 0x02;

sub is_current
{
  my $cref = shift;

  return (exists($cref->{'bufnum'}) && $cref->{'bufnum'} == $Current_ChanServ);
}

sub is_chan
{
  return ($_[0] =~ /^[&#+!]/);
}

sub is_list
{
  return ($_[0] == $Current_Server->{'list'} || $_[0] eq '*list');
}

sub process_umode
{
  my $modes = shift;

  while ($modes =~ s/^\s*([+-])(\S+)//)
    {
      my $add = ($1 eq '+');

      foreach my $mode (split(//, $2))
	{
	  if ($add)
	    {
	      unless ($Current_Server->{'umode'} =~ /$mode/)
		{
		  $Current_Server->{'umode'} .= $mode;
		}
	    }
	  else
	    {
	      $Current_Server->{'umode'} =~ s/$mode//;
	    }
	}
    }

  irc_chan_line('', "*: Your user modes: %s", $Current_Server->{'umode'});
  vim_setumode($Current_Server->{'umode'});
}

sub process_cmode
{
  my ($chan, $modes) = @_;

  if (0)
    {
      vim_printf("modes=%s", $modes);
    }

  if (my $cref = find_chan($chan))
    {
      if (my ($modes, $args) = ($modes =~ /^(\S+)(?:\s+(.+))?/))
	{
	  my ($add, $mode);
	  my @args = split(/\s+/, $args);

	  while ($mode = substr($modes, 0, 1))
	    {
	      if ($mode =~ /[-+]/)
		{
		  $add = ($mode eq '+');
		}
	      elsif ($mode =~ /[beIO]/)	# I just ignore these
		{
		  shift(@args);
		}
	      elsif ($mode =~ /[fJ]/) # dunno what these are for
		{
		  shift(@args);
		}
	      elsif ($mode eq 'k')
		{
		  if ($add)
		    {
		      $cref->{'key'} = shift(@args);
		    }
		  else
		    {
		      $cref->{'key'} = undef;
		    }
		}
	      elsif ($mode eq 'l')
		{
		  if ($add)
		    {
		      $cref->{'limit'} = shift(@args);
		    }
		  else
		    {
		      $cref->{'limit'} = 0;
		    }
		}
	      elsif ($mode =~ /[ov]/)
		{
		  my $nick = shift(@args);

		  if (my $nref = find_nick($nick, $chan))
		    {
		      my $val = $mode eq 'o' ? $UMODE_CHOP : $UMODE_VOICE;
		      if ($add)
			{
			  $nref->{'umode'} |= $val;
			  if (is_me($nick))
			    {
			      $cref->{'umode'} |= $val;
			    }
			}
		      else
			{
			  $nref->{'umode'} &= ~$val;
			  if (is_me($nick))
			    {
			      $cref->{'umode'} &= ~$val;
			    }
			}
		    }
		  draw_nickwin($chan);
		}
	      else
		{
		  if ($add)
		    {
		      if (index($cref->{'cmode'}, $mode) < 0)
			{
			  $cref->{'cmode'} .= $mode;
			}
		    }
		  else
		    {
		      $cref->{'cmode'} =~ s/$mode//;
		    }
		}
	      $modes = substr($modes, 1);
	    }
	}

	{
	  my $chan = do_escape($chan);
	  my $modes = $cref->{'cmode'};

	  if ($cref->{'key'} && $cref->{'limit'})
	    {
	      $modes .= "kl $cref->{'key'} $cref->{'limit'}";
	    }
	  elsif ($cref->{'key'})
	    {
	      $modes .= "k $cref->{'key'}";
	    }
	  elsif ($cref->{'limit'})
	    {
	      $modes .= "l $cref->{'limit'}";
	    }
	  VIM::DoCommand("call s:SetChannelMode(\"$chan\", \"$modes\")");
	}
    }
}

sub add_chan
{
  my ($chan, $key) = @_;
  my $cref;
  # We should not change cases here.  It may cause troubles with non-ascii
  # characters

  if (my $chans = $Current_Server->{'chans'})
    {
      unless (find_chan($chan))
	{
	  $cref = { name    => $chan,
		    key	    => $key,
		    limit   => 0,
		    info    => 0,
		    bufnum  => -1,
		    umode   => 0,
		    cmode   => undef,
		    nicks   => [],
		    splits  => [],
		    lines   => []
		  };
	  push(@{$chans}, $cref);
	  set_info($Current_Server, $INFO_UPDATE);
	}
    }

  return $cref;
}

sub find_chan
{
  my ($chan, $sref) = @_;

  if ($chan)
    {
      unless ($sref)
	{
	  $sref = $Current_Server;
	}

      # XXX: Here and there I'm assuming `foreach' is faster than `for'.
      # Correct me if it is wrong.
      foreach my $cref (@{$sref->{'chans'}})
	{
	  if (lc($cref->{'name'}) eq lc($chan))
	    {
	      return $cref;
	    }
	}
    }

  return undef;
}

sub del_chan
{
  my $chan  = shift;

  if (my $chans = $Current_Server->{'chans'})
    {
      for (my $i = 0; $i <= $#{$chans}; $i++)
	{
	  if (lc($chans->[$i]->{'name'}) eq lc($chan))
	    {
	      splice(@{$chans}, $i, 1);
	      set_info($Current_Server, $INFO_UPDATE);
	      last;
	    }
	}
    }
  # NOTE: Do not lower case here
  vim_close_chan($chan);
}

sub add_list
{
  my $sref = shift;

  $sref->{'list'} = { bufnum => -1, info => 0, lines => [] };
}

sub find_list
{
  my $sref = shift;

  unless ($sref)
    {
      $sref = $Current_Server;
    }

  return ($sref->{'list'}->{'bufnum'} >= 0) ? $sref->{'list'} : undef;
}

#
# User management
#

sub is_me
{
  return (lc($_[0]) eq lc($Current_Server->{'nick'}));
}

sub get_nicks
{
  if (my $cref = find_chan($_[0]))
    {
      return $cref->{'nicks'};
    }
  return undef;
}

sub init_nicks
{
  if (my $nicks = get_nicks($_[0]))
    {
      @{$nicks} = ();
    }
}

sub sort_nicks
{
  if (my $nicks = get_nicks($_[0]))
    {
      @{$nicks} = sort { $b->{'umode'} <=> $a->{'umode'} }
		  sort { lc($a->{'nick'}) cmp lc($b->{'nick'}) }
		  @{$nicks};
    }
}

# Move designated nick on top of a list, making it easier to get prefix ([@+])
# for active speakers
sub refresh_nicks
{
  my ($nick, $chan) = @_;

  if (my $nicks = get_nicks($chan))
    {
      for (my $i = 0; $i <= $#{$nicks}; $i++)
	{
	  if ($nicks->[$i]->{'nick'} eq $nick)
	    {
	      my $nref = $nicks->[$i];

	      if ($i)
		{
		  splice(@{$nicks}, $i, 1);
		  unshift(@{$nicks}, $nref);
		  return 1;
		}
	      last;
	    }
	}
    }
  return 0;
}

sub add_nick
{
  my ($nick, $mode, $chan, $force) = @_;

  if (my $cref = find_chan($chan))
    {
      if (is_me($nick))
	{
	  $cref->{'umode'} = $mode;
	}

      if ($force || !find_nick($nick, $chan))
	{
	  unshift(@{$cref->{'nicks'}}, { nick => $nick, umode => $mode });
	}
    }
}

sub find_nick
{
  my ($nick, $chan) = @_;

  if (my $nicks = get_nicks($chan))
    {
      foreach my $nref (@{$nicks})
	{
	  if ($nref->{'nick'} eq $nick)
	    {
	      return $nref;
	    }
	}
    }
  return undef;
}

sub del_nick
{
  my ($nick, $chan) = @_;

  if (my $nicks = get_nicks($chan))
    {
      for (my $i = 0; $i <= $#{$nicks}; $i++)
	{
	  if ($nicks->[$i]->{'nick'} eq $nick)
	    {
	      splice(@{$nicks}, $i, 1);
	      return 1;
	    }
	}
    }
  return 0;
}

sub change_nicks
{
  my ($old, $new, $chan) = @_;

  if (my $nref = find_nick($old, $chan))
    {
      $nref->{'nick'} = $new;
      return 1;
    }
  return 0;
}

sub find_nickprefix
{
  my ($nick, $chan) = @_;

  if (is_me($nick))
    {
      if (my $cref = find_chan($chan))
	{
	  return get_nickprefix($cref->{'umode'});
	}
    }
  else
    {
      if (my $nref = find_nick($nick, $chan))
	{
	  return get_nickprefix($nref->{'umode'});
	}
    }
  return undef;
}

sub get_nickprefix
{
  if (my $mode = $_[0])
    {
      my $pref = '';

      if ($mode & $UMODE_CHOP)
	{
	  $pref .= '@';
	}
      if ($mode & $UMODE_VOICE)
	{
	  $pref .= '+';
	}
      return $pref;
    }
  return undef;
}

sub draw_nickline
{
  my ($nick, $pref, $chan, $add) = @_;
  my $orgw = vim_winnr();

  if (vim_visit_nicks($chan))
    {
      my $orgln = ($orgw == vim_winnr()) ? VIM::Eval("getline('.')")
					 : undef;
      my $todel = vim_search("$pref$nick");

      unless ($add && $todel == 1)
	{
	  vim_modifybuf(1);
	  if ($todel)
	    {
	      $curbuf->Delete($todel);
	    }
	  if ($add)
	    {
	      $curbuf->Append(0, sprintf("%s%s", $pref, $nick));
	    }
	  vim_modifybuf(0);
	}
      if ($orgln)  # Restore the cursor position
	{
	  vim_search($orgln);
	}
      else
	{
	  # Keep top lines visible.  Since I dislike modifying the jumplist,
	  # I just set the cursor position here.
	  $curwin->Cursor(1, 0);  # but this doesn't update the view itself
	  VIM::DoCommand('normal! 0');	# so this is necessary
	}
      VIM::DoCommand("$orgw wincmd w");
    }
  else
    {
      draw_nickwin($chan);
    }
}

# TODO: Preserve the previous window (?)

sub draw_nickwin
{
  my $chan = shift;
  # Use bufnum since window number can change
  my $orgb = vim_bufnr();
  my $orgw = vim_winnr();

  if (vim_open_nicks($chan))
    {
      my $nicks = get_nicks($chan);
      my ($orgln) = ($orgw == vim_winnr()) ? $curwin->Cursor() : (0);

      vim_modifybuf(1);
      $curbuf->Delete(1, $curbuf->Count());

      foreach my $nref (@{$nicks})
	{
	  $curbuf->Append($curbuf->Count(), sprintf("%s%s",
					      get_nickprefix($nref->{'umode'}),
					      $nref->{'nick'}));
	}
      $curbuf->Delete(1);
      vim_modifybuf(0);

      if ($orgln)
	{
	  $curwin->Cursor($orgln, 0);
	}
      else
	{
	  VIM::DoCommand('normal! 0');
	}
      vim_bufvisit($orgb);
    }
  else
    {
      # Redraw later
      if (my $cref = find_chan($chan))
	{
	  set_info($cref, $INFO_UPDATE);
	}
    }
}

sub identify_nick
{
  # There might be a generalized way...
  my ($from, $mesg) = @_;
  my $nick = $Current_Server->{'nick'};
  our %NickServ;

  unless (defined(%NickServ))
    {
      $NickServ{'irc.freenode.net'} =
	{ nickserv  => 'NickServ',
	  regex	    => qr(type /msg NickServ \x02IDENTIFY\x02),
	  keyword   => 'IDENTIFY',
	};
    }

  if (my $nickserv = $NickServ{$Current_Server->{'server'}})
    {
      if ($from eq $nickserv->{'nickserv'} && ${$mesg} =~ $nickserv->{'regex'})
	{
	  unless (my $pass = $nickserv->{$nick})
	    {
	      my ($nickpass) = (vim_getvar('g:vimirc_nickpass')
				    =~ /([^,]+)\@$Current_Server->{'server'}/);
	      ($pass) = ($nickpass =~ /(?:^|\|)$nick:([^|]+)/);

	      unless ($pass)
		{
		  $pass = $nickpass;
		  unless ($pass)
		    {
		      $pass = VIM::Eval("s:InputS('Enter the nick password')");
		    }
		}
	      if ($pass)
		{
		  $nickserv->{$nick} = $pass;
		}
	    }
	  if ($nickserv->{$nick})
	    {
	      irc_chan_line('', "*: Identifying yourself...");
	      irc_send("PRIVMSG %s :%s %s",
			$nickserv->{'nickserv'},
			$nickserv->{'keyword'},
			$nickserv->{$nick});
	      return 1;
	    }
	}
    }
  return 0;
}

sub add_chat
{
  my ($nick, $sref) = @_;
  my $cref;

  if (my $chats = $sref->{'chats'})
    {
      $cref = { nick  => $nick,
		info  => 0,
		bufnum=> -1,
		lines => []
	      };
      push(@{$chats}, $cref);
      set_info($sref, $INFO_UPDATE);
    }

  return $cref;
}

sub find_chat
{
  my ($nick, $sref) = @_;

  unless ($sref)
    {
      $sref = $Current_Server;
    }

  foreach my $cref (@{$sref->{'chats'}})
    {
      if (lc($cref->{'nick'}) eq lc($nick))
	{
	  return $cref;
	}
    }

  return undef;
}

sub del_chat
{
  my ($nick, $sref) = @_;

  unless ($sref)
    {
      $sref = $Current_Server;
    }

  if (my $chats = $sref->{'chats'})
    {
      for (my $i = 0; $i <= $#{$chats}; $i++)
	{
	  if (lc($chats->[$i]->{'nick'}) eq lc($nick))
	    {
	      splice(@{$chats}, $i, 1);
	      set_info($sref, $INFO_UPDATE);
	      last;
	    }
	}
    }
  vim_close_chat($nick, $sref->{'server'});
}

sub find_chanserv
{
  my ($chan, $serv) = @_;
  my ($cref, $sref);

  if ($sref = find_server($serv))
    {
      $cref = $chan ? is_list($chan)
			? $sref->{'list'}
			: &{'find_cha'.(is_chan($chan)
					? 'n' : 't')}($chan, $sref)
		    : $sref;
    }

  return ($cref, $sref);
}

#
# Netsplit
#

sub add_netsplit
{
  my ($chan, $split) = @_;
  my $ns;

  if (my $cref = find_chan($chan))
    {
      $ns = { split => $split,
	      joins => 0,
	      nicks => {}   };
      push(@{$cref->{'splits'}}, $ns);
    }

  return $ns;
}

sub find_netsplit
{
  my ($nick, $chan, $split) = @_;

  foreach my $cref (@{$Current_Server->{'chans'}})
    {
      unless ($chan && $cref->{'name'} ne $chan)
	{
	  foreach my $ns (@{$cref->{'splits'}})
	    {
	      if ($split && $ns->{'split'} ne $split)
		{
		  next;
		}
	      if ($nick && !exists($ns->{'nicks'}->{$nick}))
		{
		  next;
		}
	      return $ns;
	    }
	  if ($chan)
	    {
	      last;
	    }
	}
    }

  return undef;
}

sub del_netsplit
{
  my ($chan, $split) = @_;

  if (my $cref = find_chan($chan))
    {
      my $splits = $cref->{'splits'};

      for (my $i = 0; $i <= $#{$splits}; $i++)
	{
	  if ($splits->[$i]->{'split'} eq $split)
	    {
	      splice(@{$splits}, $i, 1);
	      draw_nickwin($chan);
	      last;
	    }
	}
    }
}

sub add_splitnick
{
  my ($nick, $chan, $split) = @_;
  my $ns = find_netsplit(undef, $chan, $split);

  unless ($ns)
    {
      if ($ns = add_netsplit($chan, $split))
	{
	  # Forget about the leftovers?
	  add_timer(600, \&del_netsplit, [ $chan, $split ]);

	  unless (find_netsplit($nick, undef, $split))
	    {
	      irc_chan_line('', "!: Netsplit detected: %s", $split);
	    }
	}
    }

  if ($ns)
    {
      $ns->{'nicks'}->{$nick} = 1;
    }
}

sub del_splitnick
{
  my ($nick, $chan) = @_;

  if (my $ns = find_netsplit($nick, $chan))
    {
      my $split = $ns->{'split'};

      unless ($ns->{'joins'}++)
	{
	  my $tojoin = scalar(keys(%{$ns->{'nicks'}}));
	  irc_chan_line('', "*: Netjoin detected: %s, %d %s to join",
			    $split, $tojoin, ($tojoin > 1 ? 'are' : 'is'));
	}

      delete($ns->{'nicks'}->{$nick});
      unless (%{$ns->{'nicks'}})
	{
	  del_netsplit($chan, $split);
	  irc_chan_line('', "*: Netsplit is over: %s", $split);
	}
      return 1;
    }
  return 0;
}

#
# Parsing IRC messages
#

sub parse_number
{
  my ($from, $comd, $args) = @_;
  my ($to, $mesg) = (${$args} =~ /^(\S+)\s+:?(.*)$/);

  if (0)
    {
      vim_printf("from=%s comd=%s args=\"%s\"", $from, $comd, ${$args});
    }

  if ($comd == 001)	# RPL_WELCOME
    {
      set_connected(1);
      irc_chan_line('', $mesg);
    }
  elsif ($comd == 002)	# RPL_YOURHOST
    {
      irc_chan_line('', $mesg);
    }
  elsif ($comd == 003)	# RPL_CREATED
    {
      irc_chan_line('', $mesg);
    }
  elsif ($comd == 004)	# RPL_MYINFO
    {
      irc_chan_line('', $mesg);
    }
  elsif ($comd == 005)	# RPL_BOUNCE
    {
      # Most servers do not seem to use this code as what RFC suggests:
      # instead, they use it to indicate what options they have set, e.g., the
      # maximum length of nick
      # TODO: Make use of those options?
      irc_chan_line('', $mesg);
    }
  elsif ($comd == 221)	# RPL_UMODEIS
    {
      if ($mesg =~ /^(\+\S*)/)
	{
	  irc_chan_line('', "*: Your user modes: %s", $1);
	  vim_setumode($1);
	}
    }
  elsif ($comd >= 250 && $comd <= 259)  # RPL_LUSERCLIENT etc.
    {
      irc_chan_line('', $mesg);
    }
  elsif ($comd == 265 || $comd == 266)
    {
      irc_chan_line('', $mesg);
    }
  elsif ($comd == 301)	# RPL_AWAY
    {
      if (my ($nick, $mesg) = ($mesg =~ /^(\S+)\s+:(.*)$/))
	{
	  irc_chan_line('', "%s is away: %s", $nick, $mesg);
	}
    }
  elsif ($comd == 302)	# RPL_USERHOST
    {
      # Get the first one.  This should be called upon logon, to obtain user's
      # hostname.  Necessary for dcc things.
      if (my ($nick, $host) = ($mesg =~ /^([^=]+)\S+@(\S+)/))
	{
	  if (is_me($nick))
	    {
	      $Current_Server->{'local'} = $host;
	      irc_chan_line('', "*: Your local host: %s", $host);
	    }
	  else
	    {
	      irc_chan_line('', "USERHOST: %s", $mesg);
	    }
	}
    }
  elsif ($comd == 303)	# RPL_ISON
    {
      irc_chan_line('', "ISON: %s", $mesg);
    }
  elsif ($comd == 305 || $comd == 306)	# RPL_UNAWAY/RPL_NOWAWAY
    {
      irc_chan_line('', $mesg);
    }
  elsif ($comd == 311 || $comd == 314)	# RPL_WHOISUSER
    {
      if (my ($nick, $user, $host, $info) =
				  ($mesg =~ /^(\S+)\s+(\S+)\s+(\S+)\s+(.+)$/))
	{
	  irc_chan_line('', "%s %ss %s@%s %s",
			    $nick,
			    ($comd == 311 ? "i" : "wa"),
			    $user,
			    $host,
			    $info);
	}
    }
  elsif ($comd == 312)	# RPL_WHOISSERVER
    {
      if (my ($nick, $server) = ($mesg =~ /^(\S+)\s+(.+)$/))
	{
	  irc_chan_line('', "%s using %s", $nick, $server);
	}
    }
  elsif ($comd == 315)	# RPL_ENDOFWHO
    {
      irc_chan_line('', $mesg);
    }
  elsif ($comd == 317)	# RPL_WHOISIDLE
    {
      if (my ($nick, $idle, $signon) = ($mesg =~ /^(\S+)\s+(\d+)(?:\s+(\d+))?/))
	{
	  $idle = sprintf("%02d:%02d:%02d",
			  ($idle / 3600),
			  (($idle % 3600) / 60),
			  ($idle % 60));
	  irc_chan_line('', "%s has been idle for %s%s",
			    $nick,
			    $idle,
			    ($signon
			      ? ', signed on '.vim_gettime(0, $signon)
			      : ''));
	}
    }
  elsif ($comd == 318 || $comd == 369)	# RPL_ENDOFWHOIS
    {
      if (my ($nick, $mesg) = ($mesg =~ /^(\S+)\s+:?(.+)$/))
	{
	  irc_chan_line('', "%s %s", $nick, $mesg);
	}
    }
  elsif ($comd == 319)	# RPL_WHOISCHANNELS
    {
      if (my ($nick, $chan) = ($mesg =~ /^(\S+)\s+:?(.+)$/))
	{
	  irc_chan_line('', "%s on %s", $nick, $chan);
	}
    }
  elsif ($comd == 320)	# I see "is an identified user" on dancer-ircd
    {
      if (my ($nick, $mesg) = ($mesg =~ /^(\S+)\s+:?(.+)$/))
	{
	  irc_chan_line('', "%s %s", $nick, $mesg);
	}
    }
  elsif ($comd == 321)	# RPL_LISTSTART
    {
      irc_chan_line('', '*: Listing channels...');
    }
  elsif ($comd == 323)	# RPL_LISTEND
    {
      VIM::DoCommand('call s:PostLoadList(1)');
      irc_chan_line('', $mesg);
    }
  elsif ($comd == 324)	# RPL_CHANNELMODEIS
    {
      if (my ($chan, $modes) = ($mesg =~ /^(\S+)\s+:?(.+)$/))
	{
	  process_cmode($chan, $modes);
	}
    }
  elsif ($comd == 329)
    {
      if (my ($chan, $time) = ($mesg =~ /^(\S+)\s+(\d+)$/))
	{
	  irc_chan_line($chan, "*: %s came into existence on %s", $chan,
							vim_gettime(0, $time));
	}
    }
  elsif ($comd == 331)	# RPL_NOTOPIC
    {
      if (my ($chan, $mesg) = ($mesg =~ /^(\S+)\s+:?(.*)$/))
	{
	  irc_chan_line($chan, "*: %s", $mesg);
	}
    }
  elsif ($comd == 332)	# RPL_TOPIC
    {
      if (my ($chan, $topic) = ($mesg =~ /^(\S+)\s+:(.*)$/))
	{
	  irc_chan_line($chan, "*: Topic for %s:", $chan);
	  irc_chan_line($chan, "+: %s", $topic);

	  if (find_chan($chan))
	    {
	      $chan = do_escape($chan);
	      $topic= do_escape($topic);
	      VIM::DoCommand("call s:SetChannelTopic(\"$chan\", \"$topic\")");
	    }
	}
    }
  elsif ($comd == 333)
    {
      if (my ($chan, $nick, $time) = ($mesg =~ /^(\S+)\s+(\S+)\s+(\d+)$/))
	{
	  irc_chan_line($chan, "*: Topic set by %s at %s", $nick,
							vim_gettime(0, $time));
	}
    }
  elsif ($comd == 341)	# RPL_INVITING
    {
      if (my ($nick, $chan) = ($mesg =~ /^(\S+)\s+(\S+)$/))
	{
	  irc_chan_line('', "*: %s has been invited to %s", $nick, $chan);
	}
    }
  elsif ($comd == 352)	# RPL_WHOREPLY
    {
      # Discarding the hopcount
      my ($chan, $user, $host, $server, $nick, $flag, undef, $real) =
		($mesg =~ /^(\S+) (\S+) (\S+) (\S+) (\S+) (\S+) :(\d+) (.+)$/);
      irc_chan_line('', "%-16s %-12s %-3s %s@%s (%s)",
			$chan, $nick, $flag, $user, $host, $real);
    }
  elsif ($comd == 353)	# RPL_NAMREPLY
    {
      if (my ($type, $chan, $nicks) = ($mesg =~ /^(.)\s+(\S+)\s+:(.+)$/))
	{
	  if (find_chan($chan))
	    {
	      foreach my $nick (split(/\s+/, $nicks))
		{
		  my $mode = 0;
		  if ($nick =~ s/^@//)
		    {
		      $mode |= $UMODE_CHOP;
		    }
		  if ($nick =~ s/^\+//)
		    {
		      $mode |= $UMODE_VOICE;
		    }
		  add_nick($nick, $mode, $chan, 1);
		}
	    }
	  else
	    {
	      irc_chan_line('', "*: Names for %s: %s", $chan, $nicks);
	    }
	}
    }
  elsif ($comd == 366)	# RPL_ENDOFNAMES
    {
      if (my ($chan) = ($mesg =~ /^(\S+)/))
	{
	  if (find_chan($chan))
	    {
	      sort_nicks($chan);
	      draw_nickwin($chan);
	    }
	  else
	    {
	      irc_chan_line('', "*: End of names");
	    }
	}
    }
  elsif ($comd == 371 || $comd == 374)
    {
      irc_chan_line('', "INFO: %s", $mesg);
    }
  elsif ($comd == 372 || $comd == 375)	# RPL_MOTD/RPL_MOTDSTART
    {
      unless ($Current_Server->{'conn'} & $CS_RECON)
	{
	  irc_chan_line('', $mesg);
	}
    }
  elsif ($comd == 376)	# RPL_ENDOFMOTD
    {
      unless ($Current_Server->{'conn'} & $CS_RECON)
	{
	  irc_chan_line('', $mesg);
	}
      unless ($Current_Server->{'motd'})
	{
	  # Nick may have been trimmed by server
	  unless (is_me($to))
	    {
	      $Current_Server->{'nick'} = $to;
	      vim_setumode();
	    }
	  post_login_server($Current_Server);
	}
    }
  elsif ($comd == 391)	# RPL_TIME
    {
      irc_chan_line('', $mesg);
    }
  elsif ($comd >= 431 && $comd <= 433)	# ERR_NICKNAMEINUSE etc.
    {
      irc_chan_line('', $mesg);
      unless ($Current_Server->{'conn'} & $CS_LOGIN)
	{
	  if ($comd == 433)
	    {
	      $Current_Server->{'nick'} .= '_';
	    }
	  else
	    {
	      vim_beep(1);
	      $Current_Server->{'nick'} = VIM::Eval("s:Input('Enter new nick')");
	    }
	  vim_setumode();
	  irc_send("NICK %s", $Current_Server->{'nick'});
	}
    }
  elsif ($comd == 471 || $comd == 475)	# ERR_BADCHANNELKEY
    {
      if (my ($chan) = ($mesg =~ /^(\S+)/))
	{
	  del_chan($chan);
	  irc_chan_line('', "!: %s", $mesg);
	}
    }
  else
    {
      irc_chan_line('', "%s: %s", $comd, $mesg);
    }
}

sub p_322
{
  my (undef, $args) = @_;

  if (my ($chan, $num, $topic) = (${$args}
					=~ /^\S+\s+(\S+)\s+(\d+)\s+:(.*)$/))
    {
      irc_list_line($chan, $num, $topic);
    }
}

sub p_invite
{
  my ($from, $args) = @_;

  if (my ($chan) = (${$args} =~ /^\S+\s+:?(\S+)$/))
    {
      irc_chan_line('', "!: %s invites you to channel %s", $from, $chan);
      # Ask user to join
      vim_beep(2);

      if (vim_confirm("$from invites you to join $chan. Accept it"))
	{
	  VIM::DoCommand('call s:Send_JOIN("JOIN", "'.do_escape($chan).'")');
	}
    }
}

sub p_join
{
  my ($from, $args) = @_;

  if (my ($chan) = (${$args} =~ /^:?(\S+)/))
    {
      add_nick($from, 0, $chan);

      unless (del_splitnick($from, $chan))
	{
	  # If it is you who is entering, get the channel mode.
	  if (is_me($from))
	    {
	      # Keep your name from appearing twice in the nicks window,
	      # assuming NAMES are sent just after the JOIN line.  I.e.,
	      # assuming the internal nicks list contains your name only at
	      # this point in time.  I'm doing this because I don't want to
	      # check duplicates in add_nick(), for speed issue.
	      init_nicks($chan);
	      irc_send("MODE %s", $chan);
	    }
	  else
	    {
	      draw_nickline($from, undef, $chan, 1);
	    }
	  irc_chan_line($chan, "->: Enter %s [%s]", $from, $From_Server);
	}
    }
}

sub p_kick
{
  my ($from, $args) = @_;

  if (my ($chan, $nick, $mesg) = (${$args} =~ /^(\S+)\s+(\S+)\s+:(.*)$/))
    {
      my $pref = find_nickprefix($nick, $chan);

      del_nick($nick, $chan);

      if (is_me($nick))
	{
	  irc_chan_line('', "!: You have been kicked off channel %s by %s (%s)",
			    $chan, $from, $mesg);
	  del_chan($chan);
	}
      else
	{
	  draw_nickline($nick, $pref, $chan, 0);
	  irc_chan_line($chan, "!: %s kicks off %s (%s)", $from, $nick, $mesg);
	}
    }
}

sub p_mode
{
  my ($from, $args) = @_;

  if (my ($chan, $modes) = (${$args} =~ /^(\S+)\s+:?(.+)$/))
    {
      if (is_chan($chan))
	{
	  process_cmode($chan, $modes);
	  irc_chan_line($chan, "*: %s sets new mode: %s", $from, $modes);
	}
      elsif (is_me($chan))
	{
	  process_umode($modes);
	}
    }
}

sub p_nick
{
  my ($from, $args) = @_;

  if (my ($nick) = (${$args} =~ /^:(.+)$/))
    {
      if (is_me($from))
	{
	  $Current_Server->{'nick'} = $nick;
	  irc_chan_line('', "*: New nick %s approved", $nick);
	  irc_send("MODE %s", $nick);
	}

      foreach my $cref (@{$Current_Server->{'chans'}})
	{
	  my $chan = $cref->{'name'};
	  if (change_nicks($from, $nick, $chan))
	    {
	      draw_nickwin($chan);
	      irc_chan_line($chan, "*: %s is now known as %s", $from, $nick);
	    }
	}
      if (0)
	{
	  dcc_change_nicks($from, $nick);
	}
    }
}

sub p_notice
{
  my ($from, $args) = @_;

  if (my ($chan, $mesg) = (${$args} =~ /^(\S+)\s+:?(.*)$/))
    {
      unless (identify_nick($from, \$mesg)) # if not from nickserv
	{
	  if (process_ctcp_reply($from, $chan, \$mesg))
	    {
	      if (is_chan($chan))
		{
		  irc_chan_line($chan, "[%s%s]: %s",
					find_nickprefix($from, $chan),
					$from, $mesg);
		}
	      else
		{
		  &{'irc_cha'.(find_chat($from) ? 't' : 'n').'_line'}(
					      $from, "[%s]: %s", $from, $mesg);
		}
	      vim_beep(1);
	    }
	}
    }
}

sub p_part
{
  my ($from, $args) = @_;
  my ($chan, $mesg) = (${$args} =~ /^(\S+)\s+:(.*)$/);
  my $pref = find_nickprefix($from, $chan);

  if (del_nick($from, $chan))
    {
      if (is_me($from))
	{
	  del_chan($chan);
	}
      else
	{
	  draw_nickline($from, $pref, $chan, 0);
	  irc_chan_line($chan, "<-: Exit %s%s [%s] (%s)", $pref, $from,
							  $From_Server, $mesg);
	}
    }
}

sub p_ping
{
  my $args = shift;

  $Current_Server->{'lastping'} = time();
  irc_send("PONG :%s", ${$args});

  if (0)
    {
      irc_chan_line('', "Ping? Pong!");
    }
}

sub p_pong
{
  my ($from, $args) = @_;

  if (0 && (my ($time) = (${$args} =~ /(\d+)$/)))
    {
      my $diff = time() - $time;
      irc_chan_line('', "*: Pong from %s (%d second%s)", $from, $diff,
						      ($diff != 1 ? 's' : ''));
    }
}

sub p_privmsg
{
  my ($from, $args) = @_;

  if (my ($chan, $mesg) = (${$args} =~ /^(\S+)\s+:(.*)$/))
    {
      my $pref;

      if (is_chan($chan))
	{
	  $pref = find_nickprefix($from, $chan);

	  if (refresh_nicks($from, $chan))
	    {
	      draw_nickline($from, $pref, $chan, 1);
	    }
	}

      # Handle CTCP messages first
      if (process_ctcp_query($from, $pref, $chan, \$mesg))
	{
	  if (is_chan($chan))
	    {
	      irc_chan_line($chan, "<%s%s>: %s", $pref, $from, $mesg);
	    }
	  else
	    {
	      &{'irc_cha'.(is_me($chan) ? 't' : 'n').'_line'}(
					      $from, "<%s>: %s", $from, $mesg);
	      vim_beep(1);
	    }
	}
    }
}

sub p_quit
{
  my ($from, $args) = @_;
  my ($mesg)= (${$args} =~ /^:(.+)$/);
  my $regex = qr([[:alnum:]]+(?:\.[-[:alnum:]]+)+);
  my $split = ($mesg =~ /^$regex $regex$/);

  foreach my $cref (@{$Current_Server->{'chans'}})
    {
      my $chan = $cref->{'name'};
      my $pref = find_nickprefix($from, $chan);

      if (del_nick($from, $chan))
	{
	  # Handle netsplits: just hide QUIT messages if one occurs.  Also,
	  # hold the nicks, who are to be resurrected, to hide the expected
	  # JOIN messages.
	  if ($split)
	    {
	      add_splitnick($from, $chan, $mesg);
	    }
	  else
	    {
	      draw_nickline($from, $pref, $chan, 0);
	      irc_chan_line($chan, "<=: Exit %s%s [%s] (%s)", $pref, $from,
							  $From_Server, $mesg);
	    }
	}
    }
}

sub p_topic
{
  my ($from, $args) = @_;

  if (my ($chan, $topic) = (${$args} =~ /^(\S+)\s+:(.*)$/))
    {
      irc_chan_line($chan, "*: %s sets new topic: %s", $from, $topic);

	{
	  my $chan = do_escape($chan);
	  my $topic= do_escape($topic);
	  VIM::DoCommand("call s:SetChannelTopic(\"$chan\", \"$topic\")");
	}
    }
}

sub p_wallops
{
  my ($from, $args) = @_;

  if (my ($mesg) = (${$args} =~ /^:(.+)$/))
    {
      irc_chan_line('', "!%s!: %s", $from, $mesg);
      vim_beep(2);
    }
}

sub parse_line
{
  my $line = shift;

  if (my ($from, $comd, $args) = (${$line} =~ /^:(\S+)\s+(\S+)\s+(.*)$/))
    {
      ($from, $From_Server) = ($from =~ /^([^!]+)(?:!(\S+))?$/);

      if (0)
	{
	  vim_printf("from=%s server=%s comd=%s args=%s", $from, $From_Server,
								$comd, $args);
	}

      $comd = lc($comd);

      if (defined(&{'p_'.$comd}))
	{
	  &{'p_'.$comd}($from, \$args);
	}
      elsif ($comd + 0)
	{
	  parse_number($from, $comd, \$args);
	}
      else
	{
	  irc_chan_line('', "%s", ${$line});
	}
    }
  else
    {
      if (($comd, $args) = (${$line} =~ /^(\S+)\s+:?(.*)$/))
	{
	  $comd = lc($comd);
	  if (0)
	    {
	      vim_printf("comd=%s args=%s", $comd, $args);
	    }

	  if ($comd eq 'notice')
	    {
	      irc_chan_line('', "%s", $args);
	    }
	  elsif ($comd && defined(&{'p_'.$comd}))
	    {
	      &{'p_'.$comd}(\$args);
	    }
	  else
	    {
	      irc_chan_line('', "%s", ${$line});
	    }
	}
    }
}

#
# Misc. utility functions
#

# When passing string to vim, '"' and '\' must be escaped
sub do_escape
{
  my $str = shift;

  $str =~ s/(["\\])/\\$1/g;
  return $str;
}

sub do_urldecode
{
  my $str = shift;

  $str =~ s/%([[:xdigit:]]{2})/pack('C', hex($1))/eg;
  return $str;
}

sub do_urlencode
{
  my $str = shift;

  $str =~ s/([`'!@#\$%^&*(){}<>~|\\\";? ,\/])/'%'.unpack('H2', $1)/eg;
  return $str;
}

# Implements `mkdir -p'
sub my_mkdir
{
  my $dir = shift;
  # Dunno why perl doesn't have `pwd'.  Does it?
  my $cwd = VIM::Eval('getcwd()');

  unless (-d $dir)
    {
      my $tmp = $dir;
      while ($tmp =~ s#^(.+?/)##)
	{
	  unless (chdir($1) || (mkdir($1) && chdir($1)))
	    {
	      last;
	    }
	}
      unless (-d $dir)	# final check
	{
	  mkdir($dir);
	}
    }

  VIM::DoCommand("cd $cwd");
  return (-d $dir);
}

sub vim_bufnr
{
  return VIM::Eval("bufnr('%')");
}

sub vim_winnr
{
  return VIM::Eval('winnr()');
}

sub vim_getvar
{
  return VIM::Eval("exists('$_[0]')") ? scalar(VIM::Eval("$_[0]")) : undef;
}

sub vim_printf
{
  VIM::Msg(sprintf(shift(@_), @_));
}

sub vim_confirm
{
  return scalar(VIM::Eval('s:Confirm_YN("'.do_escape($_[0]).'")'));
}

sub vim_beep
{
  unless ($Current_Server->{'away'})
    {
      # XXX: Force it vomit lines, to notify user what is going wrong
      if (has_lines($Current_Server))
	{
	  put_serv_lines($Current_Server);
	}
      VIM::DoCommand("call s:Beep($_[0])");
    }
}

sub vim_search
{
  return scalar(VIM::Eval('s:SearchLine("'.do_escape($_[0]).'")'));
}

sub vim_gettime
{
  # I think Vim's strftime is much faster than perl's equivalent
  return scalar(VIM::Eval("s:GetTime($_[0], $_[1])"));
}

sub vim_get_serverumode
{
  return scalar(VIM::Eval('s:GetServerUMODE()'));
}

sub vim_setumode
{
  VIM::DoCommand("call s:SetUserMode(\"$_[0]\")");
}

sub vim_open_serv
{
  VIM::DoCommand('call s:OpenBuf_Server()');
}

sub vim_visit_serv
{
  return scalar(VIM::Eval('s:VisitBuf_Server()'));
}

sub vim_open_list
{
  VIM::DoCommand('call s:OpenBuf_List()');
}

sub vim_visit_list
{
  return scalar(VIM::Eval('s:VisitBuf_List()'));
}

sub vim_open_chan
{
  VIM::DoCommand('call s:OpenBuf_Channel("'.do_escape($_[0]).'")');
}

sub vim_visit_chan
{
  return scalar(VIM::Eval('s:VisitBuf_Channel("'.do_escape($_[0]).'")'));
}

sub vim_close_chan
{
  VIM::DoCommand('call s:CloseBuf_Channel("'.do_escape($_[0]).'")');
}

sub vim_open_nicks
{
  return scalar(VIM::Eval('s:OpenBuf_Nicks("'.do_escape($_[0]).'")'));
}

sub vim_visit_nicks
{
  return scalar(VIM::Eval('s:VisitBuf_Nicks("'.do_escape($_[0]).'")'));
}

sub vim_open_chat
{
  VIM::DoCommand('call s:OpenBuf_Chat("'.do_escape($_[0]).'", "'.$_[1].'")');
}

sub vim_visit_chat
{
  return scalar(VIM::Eval('s:VisitBuf_Chat("'.do_escape($_[0]).'", "'.$_[1].'")'));
}

sub vim_close_chat
{
  VIM::DoCommand('call s:CloseBuf_Chat("'.do_escape($_[0]).'", "'.$_[1].'")');
}

sub vim_open_info
{
  return scalar(VIM::Eval('s:OpenBuf_Info()'));
}

sub vim_bufvisit
{
  return scalar(VIM::Eval("s:BufVisit($_[0])"));
}

sub vim_winvisit
{
  VIM::DoCommand("call s:WinVisit($_[0])");
}
sub vim_modifybuf
{
  VIM::DoCommand("call s:ModifyBuf($_[0])");
}

sub vim_peekbuf
{
  VIM::DoCommand("call s:PeekBuf($_[0])");
}

EOP
endfunction
if exists('s:sid') && s:debug
  call s:PerlIRC()
endif
endif

let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions

" vim:ts=8:sts=2:sw=2:fdm=indent:
