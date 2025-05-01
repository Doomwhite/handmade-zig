# Handmade Zig

Learning Zig by following along with the [Handmade Hero](https://handmadehero.org/) series of videos by Casey Muratori.


## Debugging
The included debugger config under `.vscode/launch.json` is compatible with the [nvim-dap plugin](https://github.com/mfussenegger/nvim-dap) in Neovim and the [CodeLLDB extension](https://github.com/vadimcn/codelldb) in VS Code.

OutputDebugString is ignored by lldb, use [DebugView](https://learn.microsoft.com/en-us/sysinternals/downloads/debugview) to see those messages.
