function connectionHandler(connection) {
  // Deny the handshake when no client certificate was presented
  if (!connection.clientCertificate) {
    connection.deny();
    return;
  }

  // Allow only certificates issued to the expected organization
  const subject = connection.clientCertificate.certificates.leaf.subject;
  if (subject.includes("O=Example Inc")) {
    connection.allow();
  } else {
    connection.deny();
  }
}
