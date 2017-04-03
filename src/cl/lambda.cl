#define ABSTRACTION(T, p) (!((T >> p) & 1) && !((T >> (p + 1)) & 1))
#define APPLICATION(T, p) (!((T >> p) & 1) && ((T >> (p + 1)) & 1))
#define VARIABLE(T, p) ((T >> p) & 1)

#define REDEX(T, p) ((APPLICATION(T, p)) && (ABSTRACTION(T, (p + 2))))

#define SET(T, p) ((T) |= ((1) << (p)))

/* copy T into U starting at p */
#define COPY(T, U, p) ((U) |= ((T) << (p)))

/* returns the end of the subterm of T starting at p */
uchar lex(const ulong T,
                uchar p) {
    uchar s = 0;

LEX:
           if (ABSTRACTION(T, p)) {
        p++;
        p++;

        goto LEX;
    } else if (APPLICATION(T, p)) {
        p++;
        p++;

        s++;
        goto LEX;
    } else if (VARIABLE(T, p)) {
VAR_L:
        p++;

        if (VARIABLE(T, p)){
            goto VAR_L;
        } else {
            p++;
        } 
    } else {
        printf("Invalid term: T=%u, p=%u\n", T, p);
        return 0;
    }

    if (s--) {
        goto LEX;
    }

    return p;
}

/* in the subterm of P starting at p, replaces n with the subterm of Q starting at q */
/* FIXME: doesn't lift free variables in RHS of contractums */
ulong substitute(const ulong P,
                       uchar p,
                 const ulong Q,
                       uchar q,
                       uchar n) {
    ulong Q_t = Q >> q;
    uchar Q_s = lex(Q_t, 0);
    Q_t &= (1 << Q_s) - 1;

    ulong R = 0;
    uchar r = 0;

    uchar s = 0;
    uchar m;

    uchar sp = 0;
    bool st[50];

SUBSTITUTE:
           if (ABSTRACTION(P, p)) {
        p++;
        p++;

        r++;
        r++;

        n++;

        st[sp] = true;
        sp++;

        goto SUBSTITUTE;
    } else if (APPLICATION(P, p)) {
        p++;
        p++;

        r++;
        SET(R, r);
        r++;

        s++;

        st[sp] = false;
        sp++;
        

        goto SUBSTITUTE;
    } else if (VARIABLE(P, p)) {
        m = 0;

VAR_S:
        p++;
        if (VARIABLE(P, p)){
            m++;

            goto VAR_S;
        } else {
            p++;

            if (n == m) {
                COPY(Q_t, R, r);
                r += Q_s;
            } else {
                do {
                    SET(R, r);
                    r++;
                } while (m--);

                r++;
            }
        }
    } else {
        printf("Invalid term: P=%u, p=%u, Q=%u, q=%u, n=%u\n", P, p, Q, q, n);
        return 0;
    }

    if (s--) {
        sp--;

        if (st[sp]) {
            n--;
        }

        goto SUBSTITUTE;
    }

    return R;
}

/* does a single step of beta reduction */
ulong reduce_step(private const ulong T) {
    uchar p = 0;
    uchar s = 0;
    uchar i;

    ulong U = 0;
    uchar u = 0;

    uchar b;
    ulong c;

    bool n = true;

STEP:
    if        (REDEX(T, p)) {
        n = false;

        p++;
        p++;
        p++;
        p++;

        b = lex(T, p);
        c = substitute(T, p, T, b, 0);

        p = lex(T, b);

        COPY(c, U, u);
        u += lex(c, 0);
    } else if (ABSTRACTION(T, p)) {
        p++;
        p++;

        u++;
        u++;

        goto STEP;
    } else if (APPLICATION(T, p)) {
        p++;
        p++;

        u++;
        SET(U, u);
        u++;

        s++;
        goto STEP;
    } else if (VARIABLE(T, p)) {
        i = 0;

VAR_S:
        p++;
        if (VARIABLE(T, p)){
            i++;
            goto VAR_S;
        } else {
            p++;

            do {
                SET(U, u);
                u++;
            } while (i--);

            u++;
            }
    } else {
        printf("Invalid term: T=%u, p=%u, U=%u, u=%u\n", T, p, U, u);
        return 0;
    }

    if (s--) {
        goto STEP;
    }

    if (n) {
        return 0;   // normal form
    } else {
        return U;
    }
}

/* reduces for n steps, breaks if we reach a normal form or reduce to the same term */
ulong reduce(const ulong T,
                   ulong n) {
    ulong R = T;
    ulong U;

    while (n--) {
        U = R;
        R = reduce_step(U);

        if (!R || R == U) {
            break;
        }
    }

    return U;
}