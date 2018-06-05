include("../src/nbody_simulation.jl")

function generate_bodies_in_cell_nodes(n::Int, m::Real, v_dev::Real, L::Real)
   
    rng = MersenneTwister(n);
    velocities = v_dev * randn(rng, Float64, (3, n))
    bodies = MassBody[]

    count = 1
    for x = 0:dL:L, y = 0:dL:L, z = 0:dL:L        
        if count > n
            break
        end
        r = SVector(x, y, z)
        v = SVector{3}(velocities[:,count])
        body = MassBody(r, v, m)
        push!(bodies, body)
        count += 1           
    end
    return bodies
end

function generate_bodies_in_line(n::Int, m::Real, v_dev::Real, L::Real)
    dL = L / n^(1 / 3)
    n_line = floor(Int, L/dL)
    rng = MersenneTwister(n);
    velocities = v_dev * randn(rng, Float64, (3, n_line))
    bodies = MassBody[]
    x = y = L/2
    for i = 1:n_line       
        r = SVector(x, y, i*dL)
        v = SVector{3}(velocities[:,i])
        body = MassBody(r, v, m)
        push!(bodies, body)  
    end
    return bodies
end

function generate_random_directions(n::Int)
    theta = acos.(1 - 2 * rand(n));
    phi = 2 * pi * rand(n);
    directions = [@SVector [sin(theta[i]) .* cos(phi[i]), sin(theta[i]) .* sin(phi[i]), cos(theta[i])] for i = 1:n]
end

units = :real
units = :reduced

const T = 90.0 # °K
const kb = 1.38e-23 # J/K
const ϵ = T * kb
const σ = 3.4e-10 # m
const ρ = 1374 # kg/m^3
const m = 39.95 * 1.6747 * 1e-27 # kg
const L = 4.6σ # 10.229σ
const N = floor(Int, ρ * L^3 / m)
const R = 2.25σ   
const v_dev = 0 #sqrt(kb * T / m)
const τ = 1e-14 # σ/v
const t1 = 0.0
const t2 = 300τ
#bodies = generate_bodies_randomly(N, m, v_dev, L)
#bodies = generate_bodies_in_cell_nodes(N, m, v_dev, L)
bodies = generate_bodies_in_line(N, m, v_dev, L)
parameters = LennardJonesParameters(ϵ, σ, R)
lj_system = PotentialNBodySystem(bodies, Dict(:lennard_jones => parameters));
simulation = NBodySimulation(lj_system, (t1, t2), PeriodicBoundaryConditions(L));
result = run_simulation(simulation, Tsit5())
#result = run_simulation(simulation, VelocityVerlet(), dt=τ)