
struct Suppressed{T}
    item::T
end
Base.show(io::IO, x::Suppressed) = print(io, "<suppressed ", x.item, '>')

function print_var(io::IO, var::JuliaInterpreter.Variable)
    print("  | ")
    T = typeof(var.value)
    local val
    try
        val = repr(var.value)
        if length(val) > 150
            val = Suppressed("$(length(val)) bytes of output")
        end
    catch
        val = Suppressed("printing error")
    end
    println(io, var.name, "::", T, " = ", val)
end

print_locdesc(io::IO, frame::JuliaStackFrame) = println(io, locdesc(frame))

function print_locals(io::IO, frame::JuliaStackFrame)
    vars = JuliaInterpreter.locals(frame)
    for var in vars
        # #self# is only interesting if it has values inside of it. We already know
        # which function we're in otherwise.
        if var.name == Symbol("#self#") && (isa(var.value, Type) || sizeof(var.value) == 0)
            continue
        end
        print_var(io, var)
    end
end

function print_frame(io::IO, num::Integer, frame::JuliaStackFrame)
    print(io, "[$num] ")
    print_locdesc(io, frame)
    print_locals(io, frame)
end
