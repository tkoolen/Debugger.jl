module Debugger

using Markdown
using Base.Meta: isexpr
using REPL
using REPL.LineEdit
using REPL.REPLCompletions

using JuliaInterpreter: JuliaInterpreter, JuliaStackFrame, @lookup, Compiled, JuliaProgramCounter, JuliaFrameCode,
      finish!, enter_call_expr, step_expr!, Breakpoints

# TODO: Work on better API in JuliaInterpreter and rewrite Debugger.jl to use it
# These are undocumented functions from JuliaInterpreter.jl used by Debugger.jl`
using JuliaInterpreter: _make_stack, pc_expr,isassign, getlhs, do_assignment!, maybe_next_call!, is_call, _step_expr!, next_call!,  moduleof,
                        iswrappercall, next_line!, linenumber


const SEARCH_PATH = []
function __init__()
    append!(SEARCH_PATH,[joinpath(Sys.BINDIR,"../share/julia/base/"),
            joinpath(Sys.BINDIR,"../include/")])
    return nothing
end

export @enter

# If there are no breakpoints set we can run a lot of things in compiled mode
function maybe_compiled(stack)
    # TODO: Better way of accessing the breakpoints in JuliaInterpreter
    if length(JuliaInterpreter.Breakpoints._breakpoints) == 0
        return Compiled()
    else
        return stack
    end
end

include("LineNumbers.jl")
using .LineNumbers: SourceFile, compute_line

include("operations.jl")
include("repl.jl")
include("printing.jl")
include("commands.jl")

macro enter(arg)
    quote
        let stack = $(_make_stack(__module__,arg))
            RunDebugger(stack)
        end
    end
end

end # module
