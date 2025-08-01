vim.keymap.set('i', 'jj', '<Esc>')
vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)
vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)
vim.keymap.set('n', '<leader>gs', vim.cmd.Git)
vim.keymap.set('n', '<leader>gp', ':Git push<CR>')
-- Close tab
vim.keymap.set('n', '<C-q>', ':wq<CR>')
vim.keymap.set('i', '<C-q>', '<C-o>:q<CR>', { silent = true })
-- Move selection up and down
vim.keymap.set('n', '<M-j>', "v:m '>+1<CR>gv=gv<Esc>")
vim.keymap.set('n', '<M-k>', "v:m '<-2<CR>gv=gv<Esc>")
vim.keymap.set('v', '<M-j>', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', '<M-k>', ":m '<-2<CR>gv=gv")

vim.keymap.set('n', '<M-down>', "v:m '>+1<CR>gv=gv<Esc>")
vim.keymap.set('n', '<M-up>', "v:m '<-2<CR>gv=gv<Esc>")
vim.keymap.set('v', '<M-down>', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', '<M-up>', ":m '<-2<CR>gv=gv")

-- Append line below to current line
vim.keymap.set('n', 'J', 'mzJ`z')
-- Jump with stable cursor
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
-- Search with stable cursor
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')
-- Keep clipboard on insert
vim.keymap.set('x', '<leader>p', '"_dP')
-- Copy to OS clipboard
vim.keymap.set('n', '<leader>y', '"+y')
vim.keymap.set('v', '<leader>y', '"+y')
vim.keymap.set('n', '<leader>Y', '"+Y')
-- Nah?
vim.keymap.set('n', 'Q', '<nop>')

-- Select all
vim.keymap.set('n', '<C-a>', 'ggVG')
vim.keymap.set('i', '<C-a>', '<Esc>ggVG')
vim.keymap.set('v', '<C-a>', '<Esc>ggVG')

-- Paste
vim.keymap.set('i', '<C-v>', '<C-o>P', { noremap = true })
vim.keymap.set('i', '<C-z>', '<C-o>u', { noremap = true })
vim.keymap.set('i', '<C-r>', '<C-o><C-r>', { noremap = true })

-- Save buffer
local function save_current_buffer()
  local cursor = vim.fn.getpos '.'
  local current_mode = vim.fn.mode()
  if current_mode == 'i' then
    vim.cmd 'stopinsert'
  end
  vim.cmd('silent! ' .. [[:%s/\t/  /g]])
  vim.cmd('silent! ' .. [[:%s/ *$//g]])
  vim.cmd 'nohlsearch'
  vim.cmd 'w'
  vim.fn.setpos('.', cursor)
end
vim.keymap.set({ 'n', 'i', 'v' }, '<C-s>', save_current_buffer, { noremap = true })

local function next_word()
  local cur_line = vim.api.nvim_get_current_line()
  local cur_col = vim.fn.col '.'
  local line_len = #cur_line + 1
  local rest = cur_line:sub(cur_col)
  if cur_col >= line_len or rest:find '[^%w_]' then
    vim.cmd 'normal! w'
  else
    vim.cmd 'normal! g_l'
  end
end
vim.keymap.set({ 'n', 'i', 'v' }, '<C-Right>', next_word, { noremap = true })

local gPrefix = ''
local gCursor = {}
local function prepare_text_replacement_command()
  gCursor = vim.fn.getpos '.'
  local current_mode = vim.fn.mode()
  if current_mode == 'v' then
    gPrefix = "silent! :'b,'es"
  elseif current_mode == 'i' then
    gPrefix = 'silent! normal! :s'
  else
    gPrefix = 'silent! :s'
  end
  local pos1 = vim.fn.getpos 'v' -- [bufnum, lnum, col, off]
  local pos2 = vim.fn.getpos '.'
  if pos1[2] > pos2[2] or (pos1[2] == pos2[2] and pos1[3] > pos2[3]) then
    vim.fn.setpos("'b", pos2)
    vim.fn.setpos("'e", pos1)
  else
    vim.fn.setpos("'b", pos1)
    vim.fn.setpos("'e", pos2)
  end
end

local function indent_line()
  local cmd1 = [[/^/  /g]]
  prepare_text_replacement_command()
  vim.cmd(gPrefix .. cmd1)
  vim.fn.setpos('.', { gCursor[1], gCursor[2] + 2 })
  vim.cmd 'nohlsearch'
end

local function unindent_line()
  local cmd1 = [[/^\(  \)\|^\( \)\|^\(\t\)//]]
  prepare_text_replacement_command()
  vim.cmd(gPrefix .. cmd1)
  vim.fn.setpos('.', gCursor)
  vim.cmd 'nohlsearch'
end
vim.keymap.set({ 'n', 'v' }, '<Tab>', indent_line, { noremap = true })
vim.keymap.set({ 'n', 'v' }, '<S-Tab>', unindent_line, { noremap = true })
vim.keymap.set('i', '<Tab>', '<C-o>I<Tab><Esc>', { noremap = true })
vim.keymap.set('i', '<S-Tab>', '<C-o>I<BS><Esc>', { noremap = true })

local function comment_line()
  local ext = vim.bo.filetype
  --  print(ext)
  local cmd1 = [[/^/#/g]]
  local cmd2 = [[/^#\([ \t]*\)#/\1/g]]
  if ext == 'javascript' or ext == 'c' or ext == 'cpp' or ext == 'h' or ext == 'hpp' or ext == 'odin' or ext == 'vs' or ext == 'fs' then
    cmd1 = [[/^/\/\//g]]
    cmd2 = [[/^\/\/\([ \t]*\)\/\//\1/g]]
  elseif ext == 'lua' then
    cmd1 = [[/^/--/g]]
    cmd2 = [[/^--\([ \t]*\)--/\1/g]]
  end
  prepare_text_replacement_command()
  vim.cmd(gPrefix .. cmd1)
  vim.cmd(gPrefix .. cmd2)
  vim.fn.setpos('.', gCursor)
end
vim.keymap.set({ 'n', 'i', 'v' }, '<leader>cc', comment_line, { noremap = true, silent = true })

-- Markdown file specific
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function()
    -- Wrap words in *
    vim.keymap.set('n', '*', function()
      local word = vim.fn.expand '<cword>'
      if word == '' then
        return
      end
      local cur_pos = vim.api.nvim_win_get_cursor(0)
      vim.cmd 'normal! viw'
      vim.cmd('normal! c*' .. word .. '*')

      vim.api.nvim_win_set_cursor(0, { cur_pos[1], cur_pos[2] + 1 })
    end, { noremap = true })

    -- Get relative link from header
    vim.keymap.set('n', '<leader>cx', function()
      local git_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
      local current_file = vim.fn.expand '%:p'
      local relative_path = current_file:gsub(git_root .. '/', '')

      local line_content = vim.fn.getline '.'
      local header_name = line_content:gsub('^#+%s*', '')
      local link = header_name:gsub('%s', '-'):gsub('[^%w%-]', ''):lower()

      local result = '[' .. header_name .. ']' .. '(' .. relative_path .. '#' .. link .. ')'
      print('Copied: ' .. result)
      vim.fn.setreg('"', result)
    end, { noremap = true })
  end,
})

--
-- Quick fix navigation
--vim.keymap.set('n', '<C-k>', '<cmd>cnext<CR>zz')
--vim.keymap.set('n', '<C-j>', '<cmd>cprev<CR>zz')
--vim.keymap.set('n', '<leader>k', '<cmd>lnext<CR>zz')
--vim.keymap.set('n', '<leader>j', '<cmd>lprev<CR>zz')
-- Replace current word match
vim.keymap.set('n', '<leader>s', ':%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>')
-- Make the current file executable
-- vim.keymap.set('n', '<leader>x', '<cmd>!chmod +x %<CR>', { silent = true })
-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
-- Diagnostic keymaps
vim.keymap.set('n', '<leader>k', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', '<leader>j', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open diagnostic [E]rror messages' })
-- Jumplist
vim.keymap.set('n', '<M-h>', '<C-o>', { desc = 'Jump back in jumplist' })
vim.keymap.set('n', '<M-l>', '<C-i>', { desc = 'Jump forward in jumplist' })
-- Debugger
local dap = require 'dap'
vim.keymap.set('n', '<F9>', dap.toggle_breakpoint)
vim.keymap.set('n', '<F5>', dap.continue)
vim.keymap.set('n', '<S-F5>', dap.run_to_cursor)
vim.keymap.set('n', '<F6>', dap.step_over)
vim.keymap.set('n', '<S-F6>', dap.step_back)
vim.keymap.set('n', '<F7>', dap.step_into)
vim.keymap.set('n', '<S-F7>', dap.step_out)
vim.keymap.set('n', '<F8>', dap.pause)
vim.keymap.set('n', '<S-F8>', dap.stop)

-- [TODO] keymaps for :Trouble and :ToggleTerm
-- [TODO] keymaps for beginning of line left to wrap up?
-- [TODO] keymaps for CTRL <- and CTRL DEL in 'i', as well as CTRL S

--vim.keymap.set('i', '<C-H>', '<C-w>', { desc = 'Delete the previous word' })
vim.keymap.set('i', '<C-Del>', '<C-o>dw', { desc = 'Delete the next word' })

--vim.keymap.set('n', '<C-BS>', 'db', { desc = 'Delete the previous word' })
vim.keymap.set('n', '<C-Del>', 'dw', { desc = 'Delete the next word' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>:q<CR>', { desc = 'Exit terminal mode' })
vim.keymap.set('t', '<C-q>', '<C-\\><C-n>:q<CR>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'netrw',
  callback = function()
    pcall(vim.api.nvim_buf_del_keymap, 0, 'n', '<C-l>') -- Remove default mapping
    vim.api.nvim_buf_set_keymap(0, 'n', '<C-l>', '<C-w><C-l>', { noremap = true, silent = true })
  end,
})

local builtin = require 'telescope.builtin'
-- vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
-- vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set({ 'n', 'i' }, '<C-p>', builtin.git_files, { desc = '[S]earch git files' })
-- vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>ps', builtin.live_grep, { desc = '[S]earch all [F]iles' })
-- vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
-- vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
-- vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
-- vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

-- Slightly advanced example of overriding default behavior and theme
vim.keymap.set({ 'n', 'i', 'v' }, '<C-f>', function()
  -- You can pass additional configuration to Telescope to change the theme, layout, etc.
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = 'Fuzzily search in current buffer' })
