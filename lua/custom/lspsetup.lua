local dap = require('dap')

dap.adapters.lldb = {
  type = "executable",
  command = vim.fn.stdpath("data") .. "\\mason\\packages\\codelldb\\extension\\adapter\\codelldb.exe"
}
--require('dap-lldb').setup()

dap.configurations.c =
{
  {
    name = 'debug c',
    type = 'lldb',
    request = 'launch',
    cwd = vim.fn.getcwd(),
    program = function()
      local out_drop = vim.fn.system { 'mkdir', '-p', 'bin' }
      local out = vim.fn.system { 'bash', vim.fn.getcwd() .. '/build.sh' }
      if vim.v.shell_error ~= 0 then
        vim.notify(out_drop, vim.log.levels.ERROR)
        vim.notify(out, vim.log.levels.ERROR)
        return nil
      end
      return 'bin/c'
    end,
    args = { '-test', vim.fn.expand '~/Desktop/repos' },
    argsExpanded = true,
    stopOnEntry = false,
    runInTerminal = false,
  },
}

dap.configurations.odin =
{
  {
    name = 'Build & Run',
    type = 'lldb',
    request = 'launch',
    cwd = '${workspaceFolder}',
    program = function()
--      local out_drop = vim.fn.system { 'mkdir', '-p', 'bin' }
      local is_windows = vim.loop.os_uname().sysname == "Windows_NT"
      local exe = vim.fn.getcwd() .. (is_windows and "\\bin\\omm.exe" or "/bin/omm")

      local out = vim.fn.system { exe, 'build', '-config:debug', '-platform:windows' }
      if vim.v.shell_error ~= 0 then
        vim.notify(out_drop, vim.log.levels.ERROR)
        vim.notify(out, vim.log.levels.ERROR)
        return nil
      end
      return "${workspaceFolder}/bin/entrypoint.exe"
    end,
    stopOnEntry = false,
    args = {},
  },
}
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
