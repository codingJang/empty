command = [
    "sh",
    "-c",
    f"cd /mnt && python3 -c 'from put.{sanitized_env_id} import program_under_test; "
    f"from action.action_{self.env_id}_{self.idx} import create_fuzzing_input; "
    "program_under_test(create_fuzzing_input())'"
]
exec_result = subprocess.run(command, shell=True, 
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE, 
                                text=True, check=False, timeout=1)