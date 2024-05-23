#lang racket

;; Project 3: A church-compiler for Scheme, to Lambda-calculus

(provide church-compile
         ; provided conversions:
         church->nat
         church->bool
         church->listof
         add1
         churchify)


;; Input language:
;
; e ::= (letrec ([x (lambda (x ...) e)]) e)    
;     | (let ([x e] ...) e)  
;     | (let* ([x e] ...) e)
;     | (lambda (x ...) e)
;     | (e e ...)    
;     | x  
;     | (and e ...) | (or e ...)
;     | (if e e e)
;     | (prim e) | (prim e e)
;     | datum
; datum ::= nat | (quote ()) | #t | #f 
; nat ::= 0 | 1 | 2 | ... 
; x is a symbol
; prim is a primitive operation in list prims
; The following are *extra credit*: -, =, sub1  
(define prims '(+ * - = add1 sub1 cons car cdr null? not zero?))

; This input language has semantics identical to Scheme / Racket, except:
;   + You will not be provided code that yields any kind of error in Racket
;   + You do not need to treat non-boolean values as #t at if, and, or forms
;   + primitive operations are either strictly unary (add1 sub1 null? zero? not car cdr), 
;                                           or binary (+ - * = cons)
;   + There will be no variadic functions or applications---but any fixed arity is allowed

;; Output language:

; e ::= (lambda (x) e)
;     | (e e)
;     | x
;
; also as interpreted by Racket


;; Using the following decoding functions:

; A church-encoded nat is a function taking an f, and x, returning (f^n x)
(define (church->nat c-nat)
  ((c-nat add1) 0))

; A church-encoded bool is a function taking a true-thunk and false-thunk,
;   returning (true-thunk) when true, and (false-thunk) when false
(define (church->bool c-bool)
  (c-bool (lambda () #t) (lambda () #f)))


; A church-encoded cons-cell is a function taking a when-cons callback, and a when-null callback (thunk),
;   returning when-cons applied on the car and cdr elements
; A church-encoded cons-cell is a function taking a when-cons callback, and a when-null callback (thunk),
;   returning the when-null thunk, applied on a dummy value (arbitrary value that will be thrown away)
(define ((church->listof T) c-lst)
  ; when it's a pair, convert the element with T, and the tail with (church->listof T)
  ((c-lst (lambda (a) (lambda (b) (cons (T a) ((church->listof T) b)))))
   ; when it's null, return Racket's null
   (lambda (_) '())))







;; Write your church-compiling code below:
(define pred
  `(lambda (n)
    (lambda (f x)
      (((n (lambda (g h) (h (g f))))
        (lambda (u) x))
       (lambda (u) u)))))

(define mysub
  `(lambda (n m)
    (lambda (f x)
      ((m ,pred) n f x))))

(define Y
  `((lambda (x) (x x))
    (lambda (y)
      (lambda (f)
        (f (lambda (x)
             (((y y) f) x)))))))





; churchify recursively walks the AST and converts each expression in the input language (defined above)
;   to an equivalent (when converted back via each church->XYZ) expression in the output language (defined above)
(define (churchify e)
 (match e
   ;;cons
   
  
         ;[_ 'todo]
  [`(cons ,e1 ,e2)
      `(lambda (when-cons when-null)
         (when-cons ,(churchify e1) ,(churchify e2)))]
   ;; Handle the empty list ()
   [`()
     `(lambda (when-cons when-null)
       (when-null))]
   
   ;; Handle if expressions
  

   ;; not handling
   [`(not ,e)
     `(lambda (true-thunk false-thunk)
       ((,(churchify e) (lambda () false-thunk) (lambda () true-thunk))
        true-thunk
        false-thunk))]

;;add let expression

    
    ;; Handle `prim` with one argument
    [`(prim ,e)
     (cond
       [(member (list-ref e 0) '(add1 sub1 null? zero? not car cdr))
        `(lambda (f x) ,(list-ref prims (list-ref e 0)) ,(churchify e))]
       [else `(lambda (f x) (,(list-ref prims (list-ref e 0)) f x))])]
    
    ;; Handle `prim` with two arguments
    [`(prim ,e1 ,e2)
     (cond
       [(member (list-ref e 0) '(+ - * = cons))
        `(lambda (f x) (,(list-ref prims (list-ref e 0)) ,(churchify e1) ,(churchify e2) f x))]
       [else `(lambda (f x) (,(list-ref prims (list-ref e 0)) ,(churchify e1) ,(churchify e2)))])]
       
    
    
    
   
;letrec expression

 [`(letrec ([,f (lambda ,args ,body)]) ,e)
     `(let ([,f ((Y (lambda (,f) (lambda ,args ,(churchify body)))))])
        ,(churchify e))]

   
   
   ; Add clauses for Boolean literals here
   [`#t `(lambda (true-thunk false-thunk) (true-thunk))]
   [`#f `(lambda (true-thunk false-thunk) (false-thunk))]
  ; [`() `(lambda (x) x)]
    [`(add1 ,arg)
     `(lambda (f) (lambda (x) (f ,(churchify `(,arg f x)))))]
   ;[`(- ,n1 ,n2)
     ;`(lambda (f x) (,(mysub (churchify n1) (churchify n2)) f x))]
    [(? symbol? x)
     (cond
       [(eq? x 'add1) `(lambda (n) (lambda (f x) (f ((n f) x))))]
       [else x])]
         [`(let ([,xs ,e0s]...),e1)
          (churchify `((lambda ,xs ,e1) . ,e0s))]
         ; Handle lambda calls
         [`(lambda (,x) ,e0)
          `(lambda (,x) ,(churchify e0))]
         [`(lambda (,x . ,rest) ,e0)
          `(lambda (,x) ,(churchify `(lambda ,rest ,e0)))]
         ; Variables
         [(? symbol? x) x]
         ; Handle specific primitives like 'add1'
         [`(add1 ,arg)
     `(lambda (f x) (f ,(churchify `(,arg f x))))]
         ; Numbers
         [(? natural? nat)
          (define (wrap nat)
            (cond
              [(zero? nat) `x]
              [else `(f ,(wrap (- nat 1)))]))
          `(lambda (f) (lambda (x) ,(wrap nat)))]
         ; Generic function application
         [`(,fun ,arg)
          `(,(churchify fun) ,(churchify arg))]
         [`(,fun ,arg . ,rest)
          (churchify `((,fun ,arg) . ,rest))]))


; Takes a whole program in the input language, and converts it into an equivalent program in lambda-calc
(define (church-compile program)
  ; Define primitive operations and needed helpers using a top-level let form?
  (define todo `(lambda (x) x))
  (define myadd ``(lambda (n0) (lambda (f x) (f ((n0 f) x)))))
  (define myplus `(lambda (n0 n1) (lambda (f x) ((n1 f) ((n0 f) x)))))
  (define mymulti `(lambda (n0 n1) (lambda (f x) ((n0 (n1 f)) x))))
  (define mycons `(lambda (a b) (lambda (when-cons when-null) (when-cons a b))))
  ;(define mycar `(lambda (a b) (lambda (when-cons when-null) (when-cons a b))))
  ;(define myzero (lambda (n) (= n 0)))
  ;(define cdr x)
  ;(define null `(lambda (when-cons when-null) (when-null)))
  ;(define mysub -)
 
  
   
   ;(define add1 (lambda (n) (+ n 1))) 
  (churchify
   `(let ([add1 ,myadd]
          [+ ,myplus]
          [* ,mymulti]
          [-, mysub]
          [Y ,Y]
          [cons ,mycons]
          [`(let ([,x ,expr]) ,body)
     (let ([expr-churchified (churchify expr)]
           [body-churchified (churchify body)])
       `(lambda (env) 
          (let ([bound-val (expr-churchified env)]) 
            (body-churchified (cons (cons ',x bound-val) env)))))] 
    
          ;[car ,mycar]
          ;[null? ,null]
          ;[Y-comp ,Y-comp]
          [zero? ,todo])
      ,program)))
