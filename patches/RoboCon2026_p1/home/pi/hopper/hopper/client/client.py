from hopper.common import *


class HopperClient:
    def __init__(self):
        """
        Initialize a new HopperClient.
        """
        self.__pipes = []

    def open_pipe(self, pn, create=True, delete=False, blocking=False, use_read_buffer=False, read_buffer_terminator=b'\n'):
        """
        Open a pipe specified by a PipeName `pn`.
        """
        pipe = Pipe(pn, create=create, delete=delete, blocking=blocking,
                    use_read_buffer=use_read_buffer, read_buffer_terminator=read_buffer_terminator)
        self.__pipes.append(pipe)

    def close_pipe(self, pn):
        """
        Close a pipe specified by a PipeName `pn`.
        """
        p = self.get_pipe_by_pipe_name(pn)
        if p == None:
            raise

        p.close()
        self.__pipes.remove(p)

    def get_pipe_by_pipe_name(self, pn):
        """
        Return the Pipe object specified by PipeName `pn`.
        """
        for p in self.__pipes:
            if p.pipe_name == pn:
                return p
        return None

    def read(self, pn, _buf_size=-1):
        """
        Read content from the pipe specified by `pn`.
        """
        p = self.get_pipe_by_pipe_name(pn)
        if p == None:
            raise

        return p.read(_buf_size=_buf_size)

    def write(self, pn, buf):
        """
        Write `buf` to the PipeName specified by `pn`.
        """
        p = self.get_pipe_by_pipe_name(pn)
        if p == None:
            raise

        return p.write(buf + b'\n')
