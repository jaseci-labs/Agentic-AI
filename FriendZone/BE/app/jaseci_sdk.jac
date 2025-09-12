import from jac_cloud.jaseci.models { User }
import from jac_cloud.core.archetype{ BaseAnchor, NodeAnchor }
import from jac_cloud.jaseci.utils.logger { logger }
import from bson { ObjectId }


def get_current_user() {
    logger.debug("jaseci_sdk | get_current_user | Fetching current user");
    root_node = root;
    owner = User.Collection.find_one(filter={"root_id": root_node.__jac__.id});
    return {
        "root_id": str(root.__jac__.id),
        "email": owner.email
    };
}

def grant_permission_to_all(permission_level: str, node: any) {
    logger.debug(f"jaseci_sdk | grant_permission_to_all | Granting permission: {permission_level}");
    _.perm_grant(node, level=permission_level);
}

def grant_permission(permission_level: str, node: any, root_id: str) {
    logger.debug(f"jaseci_sdk | grant_permission | Granting permission: {permission_level} to root_id: {root_id}");
    owner = User.Collection.find_one(filter={"root_id": root_id});
    if (not root_id.startswith("n:")) {
        root_id = f"n::{root_id}";
    } 
    _.allow_root(node, BaseAnchor.ref(root_id), level=permission_level);
}

def revoke_permission(node: any, root_id: str) {
    logger.debug(f"jaseci_sdk | revoke_permission | Revoking permission from root_id: {root_id}");
    owner = User.Collection.find_one(filter={"root_id": root_id});
    if (not root_id.startswith("n:")) {
        root_id = f"n::{root_id}";
    } 
    _.disallow_root(node, BaseAnchor.ref(root_id));
}

def get_node_owner(node: any) {
    logger.debug("jaseci_sdk | get_node_owner | Fetching node owner");
    root_id = getattr(node.__jac__, "root");
    owner = User.Collection.find_one(filter={"root_id": root_id});
    if owner {
        try {
            logger.debug(f"jaseci_sdk | get_node_owner | Owner found: {owner.email}");
            return {
                "id": str(owner.id),
                "email": owner.email,
                "root_id": str(owner.root_id)
            };
        } except Exception as e {
            logger.error(f"jaseci_sdk | get_node_owner | Error fetching owner: {e}");
            return None;
        }
    } else {
        logger.debug("jaseci_sdk | get_node_owner | No owner found for the node");
        return None;
    }
}

def get_user_by_email(email: str) {
    logger.debug(f"jaseci_sdk | get_user_by_email | Fetching user by email: {email}");
    user = User.Collection.find_one({ "email": { "$regex": f"^{email}$", "$options": "i" } });
    if user {
        logger.debug(f"jaseci_sdk | get_user_by_email | User found: {user.email}");
        try {
            return {
                "id": str(user.id),
                "email": user.email,
                "root_id": str(user.root_id)
            };
        } except Exception as e {
            logger.error(f"jaseci_sdk | get_user_by_email | Error fetching user: {e}");
            return None;
        }
    } else {
        logger.debug(f"jaseci_sdk | get_user_by_email | No user found with email: {email}");
        return None;
    }
}

def get_node_by_root_id(root_id: str, node_type: str) {
    logger.debug(f"jaseci_sdk | get_node_by_root_id | Fetching node by root_id: {root_id} and name: {node_type}");
    filter = {
        "name": node_type,
        "root": ObjectId(root_id)
    };
    fetched_node = NodeAnchor.Collection.find_one(filter=filter);
    if fetched_node {
        logger.debug(f"jaseci_sdk | get_node_by_root_id | Node found");
        fetched_node = _.get_context().mem.find_by_id(fetched_node);
        return fetched_node.archetype;
    } else {
        logger.debug(f"jaseci_sdk | get_node_by_root_id | No node found with root_id: {root_id} and name: {node_type}");
        return None;
    }
}

def get_nodes(node_type_str: str, root_id: str = "") -> list {
    logger.debug(f"jaseci_sdk | get_nodes | node_type: {node_type_str}");
    filter = {"name": node_type_str};
    if root_id {
        logger.debug(f"jaseci_sdk | get_nodes | root_id: {root_id}");
        filter.update({"root": ObjectId(root_id)});
    }
    try {
        nodes = list(NodeAnchor.Collection.find(filter=filter));
        return [n.archetype for n in nodes] if nodes else [];
    } except Exception as e {
        logger.error(f"jaseci_sdk | get_nodes | error: {e}");
        return [];
    }
}