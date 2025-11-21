import tensorflow as tf
import numpy as np

# Muestra el valor aproximado y la representación en hexadecimal del número bfloat16
def print_bf16(label, value):
    bits = tf.bitcast(value, tf.uint16).numpy()
    print(f"{label} {value.numpy()}  bfloat16: {format(bits, '04x')}")


# Usa tensorflow para crear dos números en formato bfloat16
value1 = tf.constant(45.83, dtype=tf.bfloat16)
value2 = tf.constant(625.41, dtype=tf.bfloat16)

print("Valores de entrada")
print_bf16("Value1 (45.83):", value1)
print_bf16("Value2 (625.41):", value2)


# =====================
#     MULTIPLICACIÓN
# =====================
print("\nPrueba de multiplicación")

y = value1 * value2
print_bf16("x1 * x2:", y)

y = (-value1) * value2
print_bf16("(-x1) * x2:", y)

y = value1 * (-value2)
print_bf16("x1 * (-x2):", y)

y = (-value1) * (-value2)
print_bf16("(-x1) * (-x2):", y)


# =====================
#        DIVISIÓN
# =====================
print("\nPrueba de división")

y = value1 / value2
print_bf16("x1 / x2:", y)

y = (-value1) / value2
print_bf16("(-x1) / x2:", y)

y = value1 / (-value2)
print_bf16("x1 / (-x2):", y)

y = (-value1) / (-value2)
print_bf16("(-x1) / (-x2):", y)


# =====================
#   EXTRA (Opcional):
#   Por si quieres validar los casos especiales
# =====================
print("\nCasos especiales")

zero = tf.constant(0.0, dtype=tf.bfloat16)

print_bf16("0 / x2:", zero / value2)
print_bf16("x1 / 0:", value1 / zero)
print_bf16("0 / 0:", zero / zero)
