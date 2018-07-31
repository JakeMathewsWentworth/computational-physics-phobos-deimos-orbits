program simulation
	implicit none

	real(kind = 8), allocatable :: phobos(:)
	real(kind = 8), allocatable :: deimos(:)
	real(kind = 8) :: t, tmax, dt

	! Set general intial conditions
	t = 0.0d0
	tmax = 1.0d0 ! 1 orbit
	dt = 0.001

	! Set phobos inital conditions
	phobos(1) = 1.0d0	! initial x-coordinate
	phobos(2) = 0.0d0	! initial y-coordinate
	phobos(3) = 0.0d0	! initial x-velocity (vy) 
	phobos(4) = 6.30d0	! initial y-velocity (vy)

	! Set deimos inital conditions
	deimos(1) = 1.0d0	! initial x-coordinate
	deimos(2) = 0.0d0	! initial y-coordinate
	deimos(3) = 0.0d0	! initial x-velocity (vy) 
	deimos(4) = 6.30d0	! initial y-velocity (vy)

	call calculateOrbit(phobos, t, tmax, dt, 'phobos.dat')
	call calculateOrbit(deimos, t, tmax, dt, 'deimos.dat')

	stop
end program simulation

subroutine calculateOrbit(y, t, tmax, dt, fileName)
	implicit none

	integer :: num_eqns ! Number of equations
	integer :: i

	real(kind = 8), intent(in), allocatable :: y(:)
	real(kind = 8), intent(in) :: t, tmax, dt
	char(len = *), intent(in) :: fileName

	real(kind = 8), allocatable :: f1(:), f2(:), f3(:), f4(:) ! y1
	real(kind = 8), allocatable :: rhs(:) ! r.h.s
	
	! # of equations
	num_eqns = 4

	! allocate arrays to correct size
	allocate(y(num_eqns))
	allocate(rhs(num_eqns))
	allocate(f1(num_eqns))
	allocate(f2(num_eqns))
	allocate(f3(num_eqns))
	allocate(f4(num_eqns))
	

	! t = 0.0d0 ! initialize time
	! tmax = 1.0d0 ! max orbital period

	! user input for time step
	! print*, 'Enter a time-step'
	! read*, dt

	! y(1) = 1.0d0	! initial x-coordinate
	! y(2) = 0.0d0	! initial y-coordinate
	! y(3) = 0.0d0	! initial x-velocity (vy) 
	! y(4) = 6.30d0	! initial y-velocity (vy)

	! open a file for output
	open(unit = 10, file = fileName, status = 'unknown')

	! integrate forward in time
	do while (t <= tmax)
		! evaluate right-hand-side of ODEs
		call rhs_eqns(t, y, rhs)
		f1 = dt * rhs ! apply first step
	
		! evaluate right-hand-side at midpoint (Q2)
		call rhs_eqns(t + (0.5d0 * dt), y + (0.5d0 * f1), rhs)
		f2 = dt * rhs ! apply second step
		
		! evaluate the right-hand-side at Q1
		call rhs_eqns(t + (0.5d0 * dt), y + (0.5d0 * f2), rhs)
		f3 = dt * rhs ! apply third step
		
		! evaluate the right-hand-side at Q3
		call rhs_eqns(t + dt, y + f3, rhs)
		f4 = dt * rhs ! apply fourth step
		
		y = y + ((f1 + f4) / 2 + (f2 + f3)) / 3
		t = t + dt	! increment time
		
		! write out the results
		write(10, *) y(1), y(2)
	end do

	close(unit = 10)

	return
end subroutine calculateOrbit

! return the right-hand-side (rhs) of our eqns
subroutine rhs_eqns(t, y0, rhs)
	implicit none

	real(kind = 8), intent(in) :: t, y0(4)
	real(kind = 8), intent(out) :: rhs(4)
	real(kind = 8) x, y, vx, vy

	! constants normalized
	real(kind = 8), parameter :: gravity = 39.5d0, mSun = 1.0d0

	! intialize vectors
	x = y0(1)
	y = y0(2)
	vx = y0(3)
	vy = y0(4)

	! r.h.s of x-position equations
	rhs(1) = vx

	! r.h.s of y-position equations
	rhs(2) = vy

	! r.h.s of x-velocity equations
	rhs(3) = -gravity * mSun * x / (x**2 + y**2)**1.5d0

	! r.h.s of y-velocity equations
	rhs(4) = -gravity * mSun * y / (x**2 + y**2)**1.5d0

	return
end subroutine rhs_eqns





