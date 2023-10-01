import { Identity } from "@dfinity/agent";
import { AuthClient, AuthClientCreateOptions, AuthClientLoginOptions } from "@dfinity/auth-client";
import { Principal } from "@dfinity/principal";
import React, { createContext, useContext, useEffect, useState } from "react";

export const AuthContext = createContext<{
  isAuthenticated: boolean,
  authClient?: AuthClient,
  identity?: Identity,
  principal?: Principal,
  login?: () => void,
  logout?: () => Promise<void>,
  options?: UseAuthClientOptions,
}>({isAuthenticated: false});

type UseAuthClientOptions = {
  createOptions?: AuthClientCreateOptions;
  loginOptions?: AuthClientLoginOptions;
}

const defaultOptions: UseAuthClientOptions = {
  createOptions: {
    idleOptions: {
      // Set to true if you do not want idle functionality
      disableIdle: true,
    },
  },
  loginOptions: {
    identityProvider: // FIXME: NFID
      process.env.DFX_NETWORK === "ic"
        ? undefined
        : `http://localhost:8000/?canisterId=${process.env.CANISTER_ID_INTERNET_IDENTITY}`,
  },
};

/**
 *
 * @param options - Options for the AuthClient
 * @param {AuthClientCreateOptions} options.createOptions - Options for the AuthClient.create() method
 * @param {AuthClientLoginOptions} options.loginOptions - Options for the AuthClient.login() method
 * @returns
 */
export const useAuthClient = (initialOptions = defaultOptions) => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [authClient, setAuthClient] = useState<AuthClient | undefined>();
  const [identity, setIdentity] = useState<Identity | undefined>(undefined);
  const [principal, setPrincipal] = useState<Principal | undefined>(undefined);
  const [options, setOptions] = useState<UseAuthClientOptions>(initialOptions);

  useEffect(() => {
    // Initialize AuthClient
    AuthClient.create(options.createOptions).then(async (client) => {
      updateClient(client);
    });
  }, []);

  // const loginImpl = () => {
  //   authClient!.login({
  //     ...options.loginOptions,
  //     onSuccess: () => {
  //       updateClient(authClient);
  //     },
  //   });
  // };

  async function updateClient(client) {
    const isAuthenticated = await client.isAuthenticated();
    setIsAuthenticated(isAuthenticated);

    const identity = client.getIdentity();
    setIdentity(identity);

    const principal = identity.getPrincipal();
    setPrincipal(principal);

    setAuthClient(client);
  }

  // async function logoutImpl() {
  //   await authClient?.logout();
  //   await updateClient(authClient);
  // }

  return {
    isAuthenticated,
    // login,
    // logout,
    authClient,
    identity,
    principal,
    options,
  };
};

/**
 * @type {React.FC}
 */
export function AuthProvider(props: { children: any, options?: UseAuthClientOptions }) {
  const auth = useAuthClient(props.options);
  return <AuthContext.Provider value={auth}>{props.children}</AuthContext.Provider>;
};

export const useAuth = () => useContext(AuthContext);