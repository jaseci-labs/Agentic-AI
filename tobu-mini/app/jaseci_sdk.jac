import from jac_cloud.jaseci.models { User }
import from jac_cloud.jaseci.utils.logger { logger }

def get_current_user() {
    logger.debug("jaseci_sdk | get_current_user | Fetching current user");
    root_node = root;
    owner = User.Collection.find_one(filter={"root_id": root_node.__jac__.id});
    return {
        "root_id": str(root.__jac__.id),
        "email": owner.email
    };
}