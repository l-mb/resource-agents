#ifndef __CPG_OLD_DOT_H__
#define __CPG_OLD_DOT_H__

#define DO_STOP 1
#define DO_START 2
#define DO_FINISH 3
#define DO_TERMINATE 4
#define DO_SETID 5

enum {

	MSG_JOURNAL = 1,
	MSG_OPTIONS,
	MSG_REMOUNT,
	MSG_PLOCK,
	MSG_WITHDRAW,
	MSG_MOUNT_STATUS,
	MSG_RECOVERY_STATUS,
	MSG_RECOVERY_DONE,
	MSG_PLOCK_OWN,
	MSG_PLOCK_DROP,
	MSG_PLOCK_SYNC_LOCK,
	MSG_PLOCK_SYNC_WAITER,
};

/* These lengths are part of the wire protocol. */

#define MAX_OPTIONS_LEN		1024
#define MSG_NAMELEN		255

struct gdlm_header {
	uint16_t		version[3];
	uint16_t		type;		   /* MSG_ */
	uint32_t		nodeid;		 /* sender */
	uint32_t		to_nodeid;	      /* 0 if to all */
	char			name[MSG_NAMELEN];
};

struct save_msg {
	struct list_head list;
	int nodeid;
	int len;
	int type;
	char buf[0];
};

#endif

