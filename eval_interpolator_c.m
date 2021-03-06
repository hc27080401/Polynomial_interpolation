function Nk=eval_interpolator_c(tip, ep)   
		maxiter=11;
		# punctele in care vor fi evaluate polinoamele de interpolare
		x=linspace(-pi, pi, 1001);
		# valorile functiei f in abscisele x
		y=fct(x(1:1001));
		var=linspace(-1,1,1001);
		h=2*pi/1001;		
		k=2;
		Nk=2^k;
		x1=y1=zeros(Nk);
		# punctele de interpolare
		x1=linspace(-pi, pi,Nk);
		# valorile functiei f in punctele de interpolare x1
		y1(1:Nk)=fct(x1(1:Nk));
		switch   tip
			case {1}
				# caz polinom lagrange
				for l=1:1001
					poly(l)=lagrange(Nk,x(l),x1,y1);
				endfor
			case {2}
				# caz polinom newton
				for l=1:1001
					poly(l)=Newton(Nk,x(l),x1,y1);
				endfor
			case {3}

					poly=linear_spline(Nk, x,x1,y1);


			case {4}
				for l=1:1001	
					poly(l)=ncspline( x(l),x1,y1);
				endfor
				
			
			case {5}
				for l=1:1001	
					poly(l)=ccspline( x(l),x1,y1);
				endfor

			case {6}
						x1=y1=zeros(Nk);	
						x1 = linspace(-1,1,Nk);
						y1 (1:length(x1))= fct(pi*x1(1:length(x1)));
						poly=zeros(1001);

						poly=fourier(Nk,var,x1,y1,2);
						
		endswitch	

		# este calculata eroarea pentru primul set de noduri de interpolare
		E1=sqrt(h*sum((y(1:1001)- poly(1:1001)).^2));	 
		#E1=sqrt(h*sum((y(1:10)- poly(1:10)).^2));	 
		while k<maxiter
			k+=1;
			Nk=2^k;
			# punctele de interpolare			
			x1=y1=zeros(Nk);	
			# valorile functiei f in punctele de interpolare x1					
			x1=linspace(-pi, pi,Nk );
			y1(1:Nk)=fct(x1(1:Nk));
			switch   tip
					case {1}
						# caz polinom lagrange
						for l=1:1001
							poly(l)=lagrange(Nk,x(l),x1,y1);
						endfor
					case {2}
						# caz polinom newton
						for l=1:1001
						poly(l)=Newton(Nk,x(l),x1,y1);
						endfor
					case {3}
						# caz spline-uri liniare
						poly=linear_spline(Nk,x,x1,y1);
						
					case {4}
						# caz spline-uri cubice naturale
						for l=1:1001	
							poly(l)=ncspline( x(l),x1,y1);
						endfor
					case {5}
						# caz spline-uri cubice tensionate					
						for l=1:1001	
							poly(l)=ccspline( x(l),x1,y1);
						endfor
					case {6}
						# caz fourrier					
						x1=y1=zeros(Nk);	
						x1 = linspace(-1,1,Nk);
						y1 (1:length(x1))= fct(pi*x1(1:length(x1)));
						poly=zeros(1001);
						poly=fourier(Nk,var,x1,y1,2);
						
						
			endswitch
   			# este calculata eroarea in nodurile de interpolare
			E2=sqrt(h*sum((y(1:1001)- poly(1:1001)).^2));	
			#E2=sqrt(h*sum((y(1:10)- poly(1:10)).^2));	
			
			
			# interpolantul converge daca eroare este descrescatoare 
			# si daca diferenta intre 2 erori succesive este mai mica decat un epsilon dat
			if (abs(E2 - E1) < ep &&(E2-E1)<0)
					Nk=2^k;
					break;
			endif		
			
			E1=E2;
		endwhile	
		# daca numarul de pasi atinge numarul maxim de iteratii 
		# atunci se returneaza inf(polinomul nu converge)
		if k == maxiter
			Nk=inf;
		endif
		
endfunction



#===============================================================================
# 		functia pentru evaluare continua
#===============================================================================
function f=fct(x)
	f=(exp(3 * cos(x)))/(2* pi * besseli(0,3));	
endfunction


#===============================================================================
# 		Lagrange
#===============================================================================

function b = lagrange(n,a, x, y)
	
	#valoare polinom Lagrange in a
	#Intrari:
	#		a = abscisa in care se cere polinomul
	#		x = abscisele celor n+1 puncte
	#		y = ordonatele celor n+1 puncte
	#Iesiri:valoare polinom interpolare in a
	
 	b = 0;
 	for i = 1 : n
   		produs = y(i);
   		for j = 1 : n
     			if i != j
        			produs = produs * ( ( a - x( j ) ) / ( x( i ) - x( j ) ));
     			endif
   		endfor
   		b = b + produs;
 	endfor

endfunction


#===============================================================================
# 		Newton
#===============================================================================

function b=Newton(n, a, x, y)
	
	#valoare polinom Newton in a
	#Intrari:
	#		a = abscisa in care se cere polinomul
	#		x = abscisele celor n+1 puncte
	#		y = ordonatele celor n+1 puncte
	#Iesiri:valoare polinom interpolare in a
	
	for k=1:n-1
		y(k+1:n)=(y(k+1:n)-y(k))./(x(k+1:n)-x(k));
	endfor
	c=y(:);
	 b=c(1);
	 p=1;
	for i=2:n
		p=(a-x(i-1)).*p;
		b=b+p*c(i);
	endfor

endfunction



#===============================================================================
# 		Fourrier
#===============================================================================

function  yInt=fourier(n,xInt,x,y,L)
	n = length(x);
	m = n/2; 
	xx = [x(m+1:n),x(1:m)]';	
	yy = [y(m+1:n),y(1:m)]';	
	for j = 0 : m
		a(j+1) = 2*yy'*cos(2*pi*j*xx/L)/n;
		b(j+1) = 2*yy'*sin(2*pi*j*xx/L)/n;
	endfor
	a';
	b'; 
	yInt = 0.5*a(1)*ones(1,length(xInt));
	for j = 1 : (m-1)
		yInt = yInt + a(1+j)*cos(2*pi*j*xInt/L) + b(1+j)*sin(2*pi*j*xInt/L);
	endfor
	yInt = yInt + a(m+1)*cos(2*pi*m*xInt/L);
endfunction


#===============================================================================
# 		Linear Spline
#===============================================================================

function f=linear_spline(n,xInt,x,y)

		n = length(x)-1; 
		a = y(1:n);
		b = (y(2:n+1)-y(1:n))./(x(2:n+1)-x(1:n));
		for j = 1 : length(xInt)
			if xInt(j) ~= x(n+1)
				iInt(j) = sum(x <= xInt(j));

			  else
			 iInt(j) = n;
			end
		end
		yInt = a(iInt) + b(iInt).*(xInt-x(iInt));
		f=yInt;
endfunction


#===============================================================================
# 	Natural Cubic Spline
#===============================================================================

function yy=ncspline(xx, x,y)
	h=diff(x);
	n=length(x)-1;
  
	a(1:n+1)=y(1:n+1);
	A=sparse(2:n,1:n-1,h(1:n-1),n+1,n+1) + ...
	  sparse(2:n,3:n+1,h(2:n),n+1,n+1) + ...
	  sparse(2:n,2:n,2*(h(1:n-1)+h(2:n)),n+1,n+1);
	A(1,1)=1; A(n+1,n+1)=1;
	b=[0,3./h(2:n).*(a(3:n+1)-a(2:n))-3./h(1:n-1).*(a(2:n)-a(1:n-1)),0]';
	c=(A\b)';
	b=(a(2:n+1)-a(1:n))./h-h./3.*(2*c(1:n)+c(2:n+1));
	d=(c(2:n+1)-c(1:n))./(3*h);
	c=c(1:n);
	for i=1:n
		if xx>=x(i) & xx<=x(i+1);
			  yy=a(i)+b(i)*(xx-x(i))+c(i)*(xx-x(i)).^2+d(i)*(xx-x(i)).^3;
			  break;
		endif
	endfor
endfunction


#===============================================================================
# 		Clamped Cubic Spline
#===============================================================================

function yy=ccspline(xx,x,y)
%CCSPLINE  Clamped Cubic Spline		
		h=diff(x);
		n=length(x)-1;
		fa=(y(2)-y(1))/(x(2)-x(1));
		fb=(y(n+1)-y(n))/(x(n+1)-x(n));
		a(1:n+1)=y(1:n+1);
		A=sparse(2:n+1,1:n,h,n+1,n+1) + ...
		  sparse(1:n,2:n+1,h,n+1,n+1) + ...
		  sparse(2:n,2:n,2*(h(1:n-1)+h(2:n)),n+1,n+1);
		A(1,1)=2*h(1); A(n+1,n+1)=2*h(n);
		b=[3./h(1)*(a(2)-a(1))-3*fa,3./h(2:n).*(a(3:n+1)-a(2:n))-3./h(1:n-1).*(a(2:n)-a(1:n-1)),3*fb-3/h(n)*(a(n+1)-a(n))]';
		c=(A\b)';
		b=(a(2:n+1)-a(1:n))./h-h./3.*(2*c(1:n)+c(2:n+1));
		d=(c(2:n+1)-c(1:n))./(3*h);
		c=c(1:n);
		for i=1:n
		if xx>=x(i) & xx<=x(i+1);
			  yy=a(i)+b(i)*(xx-x(i))+c(i)*(xx-x(i)).^2+d(i)*(xx-x(i)).^3;
			  break;
		endif
	endfor
endfunction

