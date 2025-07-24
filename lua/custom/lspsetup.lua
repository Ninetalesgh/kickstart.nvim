local lspconfig = require 'lspconfig'

lspconfig.ols.setup {
  init_options = {
    checker_args = '-strict-style',
    collection = {
      { name = 'shared', path = vim.fn.expand '$ODIN_ROOT' },
    },
  },
}

local gdscript_config = {
  name = 'gdscript',
  cmd = { 'socat', 'stdio', 'tcp:localhost:6005' },
  filetypes = { 'gdscript' },
  root_dir = lspconfig.util.root_pattern('project.godot', '.git'),
  capabilities = { textDocument = { completion = { completionItem = { snippetSupport = false } } } },
}

local cfg = {
  configurations = {
    odin = {
      {
        name = 'Build & Run',
        type = 'lldb',
        request = 'launch',
        cwd = '${workspaceFolder}',
        program = function()
          local out_drop = vim.fn.system { 'mkdir', '-p', 'build' }
          local out = vim.fn.system { 'odin', 'build', '.', '-out:build/mmodin', '-debug' }
          if vim.v.shell_error ~= 0 then
            vim.notify(out_drop, vim.log.levels.ERROR)
            vim.notify(out, vim.log.levels.ERROR)
            return nil
          end
          return 'build/mmodin'
        end,
        stopOnEntry = false,
        args = {},
      },
    },
    cpp = {
      name = 'debug godot editor',
      type = 'lldb',
      request = 'launch',
      program = '${workspaceFolder}/bin/editor_debug --editor --path ~/Desktop/repos/mythmakers',
      --args = { '--path', vim.fn.expand '~/Desktop/repos/mythmakers' },
      argsExpanded = true,
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
      runInTerminal = false,
      env = {
        GODOT_DEBUG = '1',
      },
    },
  },
}

-- require('dap').configurations = {}
--package.loaded['dap'] = nil

-- require('dap-lldb').configurations = {}
-- package.loaded['dap-lldb'] = nil
require('dap-lldb').setup(cfg)
--[[
local debugger = vim.fn.exepath 'lldb'
if debugger ~= '' then
  dap.adapters.lldb = {
    type = 'executable',
    command = debugger,
  }
  dap.configurations.lldb = {
    {
      type = 'lldb',
      name = 'debug',
      task = 'build/raw',
      request = 'launch',
      program = '${workspaceFolder}/build/raw',
      exitAfterTaskReturns = false,
      debugAutoInterpretAllModules = false,
    },
  }
end
--]]
