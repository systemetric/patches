import json


class PipeReader:
    def __init__(self, client, pipe_name):
        self._HOPPER_CLIENT = client
        self._PIPE_NAME = pipe_name

    def read(self):
        return self._HOPPER_CLIENT.read(self._PIPE_NAME)


class JsonReader(PipeReader):
    def __init__(self, client, pipe_name, read_validator=None):
        super().__init__(client, pipe_name)

        self.read_validator = read_validator if read_validator else self.default_read_validator
        self.tail = ""

        if not self._HOPPER_CLIENT.get_pipe_by_pipe_name(pipe_name).blocking:
            print("WARN: Non-blocking reads may crash the brain!")

    @staticmethod
    def default_read_validator(_):
        return True

    def _try_decode_json(self, s):
        decoder = json.JSONDecoder()
        idx = 0
        while idx < len(s):
            slice = s[idx:].lstrip()
            if not slice:
                break
            offset = len(s[idx:]) - len(slice)
            try:
                obj, end = decoder.raw_decode(slice)
                if self.read_validator(obj):
                    idx += offset + end
                    return obj, s[idx:].rstrip()
                else:
                    idx += 1
            except json.JSONDecodeError as e:
                idx += 1
        return None, s

    def read(self):
        buffer = self.tail
        chunk_size = 1024
        max_buffer_size = 1024 * 1024

        while len(buffer) < max_buffer_size:
            try:
                chunk = self._HOPPER_CLIENT.read(
                    self._PIPE_NAME, _buf_size=chunk_size)
                if not chunk:
                    break

                buffer += chunk.decode("utf-8")

                obj, tail = self._try_decode_json(buffer)

                if obj:
                    self.tail = tail
                    return obj

            except BlockingIOError:
                continue

        return None
