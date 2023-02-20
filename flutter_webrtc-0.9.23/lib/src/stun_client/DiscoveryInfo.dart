import 'dart:io';

class DiscoveryInfo {
  InternetAddress? testIP;
  bool error = false;
  int errorResponseCode = 0;
  String? errorReason;
  bool openAccess = false;
  bool blockedUDP = false;
  bool fullCone = false;
  bool restrictedCone = false;
  bool portRestrictedCone = false;
  bool symmetric = false;
  bool symmetricUDPFirewall = false;
  InternetAddress? publicIP;

  DiscoveryInfo(InternetAddress testIP) {
    this.testIP = testIP;
  }

  bool isError() {
    return error;
  }

  void setError(int responseCode, String reason) {
    this.error = true;
    this.errorResponseCode = responseCode;
    this.errorReason = reason;
  }

  bool isOpenAccess() {
    if (error) {
      return false;
    }
    return openAccess;
  }

  void setOpenAccess() {
    this.openAccess = true;
  }

  bool isBlockedUDP() {
    if (error) {
      return false;
    }
    return blockedUDP;
  }

  void setBlockedUDP() {
    this.blockedUDP = true;
  }

  bool isFullCone() {
    if (error) {
      return false;
    }
    return fullCone;
  }

  void setFullCone() {
    this.fullCone = true;
  }

  bool isPortRestrictedCone() {
    if (error) {
      return false;
    }
    return portRestrictedCone;
  }

  void setPortRestrictedCone() {
    this.portRestrictedCone = true;
  }

  bool isRestrictedCone() {
    if (error) {
      return false;
    }
    return restrictedCone;
  }

  void setRestrictedCone() {
    this.restrictedCone = true;
  }

  bool isSymmetric() {
    if (error) {
      return false;
    }
    return symmetric;
  }

  void setSymmetric() {
    this.symmetric = true;
  }

  bool isSymmetricUDPFirewall() {
    if (error) {
      return false;
    }
    return symmetricUDPFirewall;
  }

  void setSymmetricUDPFirewall() {
    this.symmetricUDPFirewall = true;
  }

  InternetAddress? getPublicIP() {
    return publicIP;
  }

  InternetAddress? getLocalIP() {
    return testIP;
  }

  void setPublicIP(InternetAddress publicIP) {
    this.publicIP = publicIP;
  }

  String toString() {
    StringBuffer sb = new StringBuffer();
    sb.write("Network interface: ");
    // try {
    //     sb.write(NetworkInterface.(testIP).getName());
    // } on SocketException catch (se) {
    //     sb.write("unknown");
    // }
    sb.write("\n");
    sb.write("Local IP address: ");
    sb.write(testIP!.address);
    sb.write("\n");
    if (error) {
      sb.write(
          (errorReason! + " - Responsecode: ") + errorResponseCode.toString());
      return sb.toString();
    }
    sb.write("Result: ");
    if (openAccess) {
      sb.write("Open access to the Internet.\n");
    }
    if (blockedUDP) {
      sb.write("Firewall blocks UDP.\n");
    }
    if (fullCone) {
      sb.write("Full Cone NAT handles connections.\n");
    }
    if (restrictedCone) {
      sb.write("Restricted Cone NAT handles connections.\n");
    }
    if (portRestrictedCone) {
      sb.write("Port restricted Cone NAT handles connections.\n");
    }
    if (symmetric) {
      sb.write("Symmetric Cone NAT handles connections.\n");
    }
    if (symmetricUDPFirewall) {
      sb.write("Symmetric UDP Firewall handles connections.\n");
    }
    if (((((((!openAccess) && (!blockedUDP)) && (!fullCone)) &&
                    (!restrictedCone)) &&
                (!portRestrictedCone)) &&
            (!symmetric)) &&
        (!symmetricUDPFirewall)) {
      sb.write("unkown\n");
    }
    sb.write("Public IP address: ");
    if (publicIP != null) {
      sb.write(publicIP!.address);
    } else {
      sb.write("unknown");
    }
    sb.write("\n");
    return sb.toString();
    return "";
  }
}
