#!/usr/bin/env python3
"""
Pequeño renderer de prueba para el bloque <#list payments as payment> en BenRegio.coffee.
Hace una interpretación muy básica de `${...}` y de las funciones usadas: setPadding, formatAmount, getAmount.
No es un motor FreeMarker completo — sólo suficiente para validar el contador `totalLines` y la salida de ejemplo.
"""
import re
from decimal import Decimal


def setPadding(value, direction='left', pad_char=' ', width=None):
    s = str(value)
    if width is None:
        return s
    try:
        w = int(width)
    except Exception:
        return s
    if direction == 'left':
        return s.rjust(w, pad_char)
    else:
        return s.ljust(w, pad_char)


def formatAmount(value, mode='dec'):
    # value expected number or numeric string
    try:
        d = Decimal(str(value))
    except Exception:
        return str(value)
    if mode == 'dec':
        # keep two decimals and no thousand separators
        return f"{d:.2f}"
    if mode == 'noDec':
        # remove decimal point and decimals
        return str(int(d))
    return str(d)


def getAmount(payment):
    return payment.get('amount', 0)


def resolve_variable(var_expr, context):
    # acceso tipo payment.memo o cbank.field
    parts = var_expr.split('.')
    cur = context
    for p in parts:
        p = p.strip()
        if isinstance(cur, dict) and p in cur:
            cur = cur[p]
        else:
            # not found, return empty
            return ''
    return cur


def split_args(s):
    args = []
    cur = ''
    depth = 0
    in_quote = False
    quote_char = ''
    for ch in s:
        if ch in ('"', "'"):
            if not in_quote:
                in_quote = True
                quote_char = ch
                cur += ch
                continue
            elif quote_char == ch:
                in_quote = False
                cur += ch
                continue
        if in_quote:
            cur += ch
            continue
        if ch == '(':
            depth += 1
            cur += ch
            continue
        if ch == ')':
            depth -= 1
            cur += ch
            continue
        if ch == ',' and depth == 0:
            args.append(cur.strip())
            cur = ''
            continue
        cur += ch
    if cur.strip():
        args.append(cur.strip())
    return args


def eval_expr(expr, context):
    expr = expr.strip()
    # string literal
    if (expr.startswith('"') and expr.endswith('"')) or (expr.startswith("'") and expr.endswith("'")):
        return expr[1:-1]

    # function call
    m = re.match(r'^([a-zA-Z_][a-zA-Z0-9_]*)\((.*)\)$', expr)
    if m:
        fname = m.group(1)
        raw_args = m.group(2)
        args = split_args(raw_args)
        evaled = [eval_expr(a, context) for a in args]
        if fname == 'setPadding':
            # setPadding(value, direction, padChar, width)
            val = evaled[0] if len(evaled) > 0 else ''
            direction = evaled[1] if len(evaled) > 1 else 'left'
            padChar = evaled[2] if len(evaled) > 2 else ' '
            width = evaled[3] if len(evaled) > 3 else None
            return setPadding(val, direction, padChar, width)
        if fname == 'formatAmount':
            val = evaled[0] if len(evaled) > 0 else 0
            mode = evaled[1] if len(evaled) > 1 else 'dec'
            return formatAmount(val, mode)
        if fname == 'getAmount':
            # argument will be payment
            arg0 = args[0].strip()
            if arg0 == 'payment':
                return getAmount(context['payment'])
            # otherwise try resolving
            v = eval_expr(args[0], context)
            return getAmount(v) if isinstance(v, dict) else v
        # unknown function -> return raw
        return f"{fname}({', '.join(map(str, evaled))})"

    # numeric literal
    if re.match(r'^-?\d+(\.\d+)?$', expr):
        return Decimal(expr) if '.' in expr else int(expr)

    # variable access
    return resolve_variable(expr, context)


def render_block(block_lines, context):
    out = []
    expr_re = re.compile(r"\$\{([^}]+)\}")
    for line in block_lines:
        def repl(m):
            inner = m.group(1)
            val = eval_expr(inner, context)
            return str(val)
        rendered = expr_re.sub(repl, line)
        out.append(rendered)
    return out


def main():
    # Leer template
    template_path = 'BenRegio.coffee'
    with open(template_path, 'r', encoding='utf-8') as f:
        src = f.read()

    # Extraer el bloque entre <#list payments as payment> y </#list>
    m = re.search(r'<#list\s+payments\s+as\s+payment>(.*?)</#list>', src, re.S)
    if not m:
        print('No se encontró el bloque <#list payments as payment> en', template_path)
        return
    block = m.group(1).strip('\n').splitlines()

    # Fixture: dos pagos de ejemplo y cbank
    payments = [
        {
            'custbody_dr_banyax_type_transfer': 'A',
            'custpage_eft_custrecord_2663_entity_acct_no': '1234567890123456',
            'amount': '1500.50',
            'memo': 'Pago test 1',
            'custbody_dr_banyax_ref_number': 'REF001'
        },
        {
            'custbody_dr_banyax_type_transfer': 'B',
            'custpage_eft_custrecord_2663_entity_acct_no': '9876543210987654',
            'amount': '250.00',
            'memo': 'Pago test 2',
            'custbody_dr_banyax_ref_number': 'REF002'
        }
    ]

    cbank = {
        'custpage_eft_custrecord_2663_acct_num': '55555555555555555555'
    }

    # Render
    total_lines = 0
    rendered_lines = []
    for p in payments:
        ctx = {'payment': p, 'cbank': cbank}
        # dentro del bloque puede haber sangrados y comentarios; renderizamos cada línea
        out_lines = render_block(block, ctx)
        # Filtrar líneas vacías y las que son comentarios del template
        for ol in out_lines:
            stripped = ol.rstrip('\n')
            if stripped.strip() == '':
                continue
            if stripped.strip().startswith('<#--'):
                continue
            rendered_lines.append(stripped)
            total_lines += 1

    # Imprimir resultado
    print('--- Render de fixture (líneas generadas) ---')
    for rl in rendered_lines:
        print(rl)
    print('--- Resumen ---')
    print('totalLines =', total_lines)


if __name__ == '__main__':
    main()
