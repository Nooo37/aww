
  
#include <stdint.h>
#include <sys/mman.h>
#include <unistd.h>
#include <fcntl.h>
#include <time.h>
#include <errno.h>
#include <err.h>
#include <lua.h>
#include <lauxlib.h>

static void randname(char *buf)
{
    struct timespec ts;
    clock_gettime(CLOCK_REALTIME, &ts);
    long r = ts.tv_nsec;
    for (int i = 0; i < 6; ++i) {
        buf[i] = 'A'+(r&15)+(r&16)*2;
        r >>= 5;
    }
}

static int create_shm_file(void)
{
    int retries = 100;
    do {
        char name[] = "/wl_shm-XXXXXX";
        randname(name + sizeof(name) - 7);
        --retries;
        int fd = shm_open(name, O_RDWR | O_CREAT | O_EXCL, 0600);
        if (fd >= 0) {
            shm_unlink(name);
            return fd;
        }
    } while (retries > 0 && errno == EEXIST);
    return -1;
}

int allocate_shm_file(size_t size)
{
    int fd = create_shm_file();
    if (fd < 0)
        return -1;
    int ret;
    do {
        ret = ftruncate(fd, size);
    } while (ret < 0 && errno == EINTR);
    if (ret < 0) {
        close(fd);
        return -1;
    }
    return fd;
}

int allocate_shm(lua_State* L)
{
    size_t size = luaL_checknumber(L, 1);
    int fd = allocate_shm_file(size);
    uint32_t *data = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
	if (data == MAP_FAILED)
		err(1, "Failed mmap\n");

    lua_pushinteger(L, fd);
    lua_pushlightuserdata(L, data);
    return 2;
}

int destroy_shm(lua_State* L)
{
    int fd = luaL_checknumber(L, 1);
    void *data = (void*) lua_topointer(L, 2);
    int size = luaL_checknumber(L, 3);
    munmap(data, size);
    close(fd);
    return 0;
}

int get_pixel(lua_State* L)
{
    const uint32_t* data = lua_topointer(L, 1);
    int x = luaL_checknumber(L, 2);
    int y = luaL_checknumber(L, 3);
    int width = luaL_checknumber(L, 4);
    uint32_t pixel = data[y * width + x];
    lua_pushnumber(L, pixel);
    return 1;
}

int set_pixel(lua_State* L)
{
    uint32_t* data = (void*) lua_topointer(L, 1);
    uint32_t pixel = luaL_checknumber(L, 2);
    int x = luaL_checknumber(L, 3);
    int y = luaL_checknumber(L, 4);
    int width = luaL_checknumber(L, 5);
    data[y * width + x] = pixel;
    return 0;
}

static const luaL_Reg _helpers[] = {
    { "allocate_shm", allocate_shm },
    { "destroy_shm",  destroy_shm },
    { "get_pixel",    get_pixel },
    { "set_pixel",    set_pixel },
    { NULL, NULL }
};

int luaopen_helpers(lua_State* L)
{
    lua_newtable(L);
    luaL_setfuncs(L, _helpers, 0);
    return 1;
}
