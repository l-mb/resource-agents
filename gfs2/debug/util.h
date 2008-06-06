#ifndef __UTIL_DOT_H__
#define __UTIL_DOT_H__


int check_type(char *data, unsigned int type);


typedef void (*pointer_call_t)(struct gfs2_dinode *di,
			       unsigned int height, uint64_t bn,
			       void *opaque);
void recursive_scan(struct gfs2_dinode *di,
		    unsigned int height, uint64_t bn,
		    pointer_call_t pc, void *opaque);

typedef void (*leaf_call_t)(struct gfs2_dinode *di, char *data,
			    uint32_t index, uint32_t len, uint64_t leaf_no,
			    void *opaque);
void foreach_leaf(struct gfs2_dinode *di,
		  leaf_call_t lc, void *opaque);


int gfs2_block_map(struct gfs2_dinode *di,
		  uint64_t lblock, uint64_t *dblock);
int gfs2_readi(struct gfs2_dinode *di, void *buf,
	      uint64_t offset, unsigned int size);


#endif /* __UTIL_DOT_H__ */

