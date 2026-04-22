import from "@mantine/core" { Alert, Group, Text, Button }
import from "@tabler/icons-react" { IconAlertCircle }

"""Reusable error alert for consistent user-facing error display."""
def:pub ErrorAlert(
    error: any = None,
    onClose: any = None,
    onRetry: any = None
) -> JsxElement {
    if not error {
        return <></>;
    }

    code = error.code or "ERR_UNKNOWN_FRONTEND";
    message = error.message or "Something went wrong. Please try again.";
    retryable = error.retryable or False;

    return <Alert
        icon={<IconAlertCircle size={16} />}
        color="red"
        variant="light"
        withCloseButton
        onClose={onClose}
        styles={{
            "root": {
                "background": "rgba(239, 68, 68, 0.08)",
                "border": "1px solid rgba(239, 68, 68, 0.25)"
            },
            "message": {"color": "#fecaca"}
        }}
    >
        <Group justify="space-between" align="center" wrap="nowrap">
            <Text size="sm">
                {"[" + code + "] " + message}
            </Text>
            {(
                <Button
                    size="xs"
                    variant="outline"
                    color="red"
                    onClick={onRetry}
                >
                    Retry
                </Button>
                if retryable and onRetry
                else None
            )}
        </Group>
    </Alert>;
}
