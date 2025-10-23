import os

from .pipe_name import PipeName

"""
Pipe class:
    Represents a single input/output pipe.
    Implements basic read/write operations.
"""


class Pipe:
    __BUF_SIZE = 1024
    __fd = 0
    __pn = None
    __handler = None

    def __init__(self, pn: PipeName, create=False, delete=False, blocking=False, use_read_buffer=False, read_buffer_terminator=b'\n', buffer_size=1024):
        self.__pn = pn
        self.__create = create
        self.__delete = delete
        self.__blocking = blocking
        self.__use_read_buffer = use_read_buffer
        self.__read_buffer_terminator = read_buffer_terminator
        self.__BUF_SIZE = buffer_size

        # The read buffer with non-blocking I/O, blocks, but not nicely
        if not self.__blocking and self.__use_read_buffer:
            print("WARN: Buffered reads with non-blocking I/O can crash the brain!")

        self.__open()

    def __open(self):
        if self.__pn == None:
            return

        pipe_path = self.__pn.pipe_path

        if not os.path.exists(pipe_path) and self.__create:
            os.mkfifo(pipe_path)
        elif not os.path.exists(pipe_path):
            raise FileNotFoundError(f"Cannot find pipe at '{pipe_path}'.")

        flags = os.O_RDWR
        flags |= (0 if self.__blocking else os.O_NONBLOCK)

        self.__fd = os.open(pipe_path, flags)
        self.__inode_number = os.stat(pipe_path).st_ino

    def read(self, _buf_size=-1):
        if self.__use_read_buffer:
            buf = b''
            # Consume greedily, until we reach the terminator
            while True:
                try:
                    b = os.read(self.__fd, 1)
                    buf += b
                    if b == self.__read_buffer_terminator:
                        break
                except BlockingIOError:
                    continue
                except:
                    return None
            return buf

        try:
            buf = os.read(
                self.__fd, self.__BUF_SIZE if _buf_size == -1 else _buf_size)
        except:
            return None
        return buf

    def write(self, buf):
        try:
            os.write(self.__fd, buf)
        except:
            raise

    def close(self):
        if self.__pn == None:
            return

        os.close(self.__fd)
        if self.__delete:
            os.remove(self.__pn.pipe_path)

    def __del__(self):
        self.close()

    def set_handler(self, handlers):
        if self.__pn == None:
            raise ValueError("Bad pipe name")

        try:
            self.__handler = handlers[self.__pn.handler_id]
        except:
            raise

    @property
    def type(self):
        if self.__pn == None:
            return None
        return self.__pn.type

    @property
    def id(self):
        if self.__pn == None:
            return None
        return self.__pn.id

    @property
    def handler_id(self):
        if self.__pn == None:
            return None
        return self.__pn.handler_id

    @property
    def pipe_name(self):
        if self.__pn == None:
            return None
        return self.__pn

    @property
    def pipe_path(self):
        if self.__pn == None:
            return None
        return self.__pn.pipe_path

    @property
    def handler(self):
        return self.__handler

    @property
    def fd(self):
        return self.__fd

    @property
    def inode_number(self):
        return self.__inode_number

    @property
    def blocking(self):
        return self.__blocking
